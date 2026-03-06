package middleware

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"reflect"
	"regexp"
	"strings"
	"time"

	"github.com/99designs/gqlgen/graphql"
	"github.com/golang-jwt/jwt/v5"
	"github.com/vektah/gqlparser/v2/gqlerror"
)

// contextKey 是 context key 的私有类型，防止外部冲突。
type contextKey string

// UserContextKey 用于在 context 中存取认证用户信息。
const UserContextKey contextKey = "user"

// TenantContextKey 用于在 context 中存取 tenant_id（供中间件内部使用）。
const TenantContextKey contextKey = "tenant"

// 跨包桥接键（schema/policy helper 与 GraphQL directive 共用）。
const (
	ActorAttrsBridgeKey = "actor_attrs"
	ActorRoleBridgeKey  = "actor_role"
	TenantIDBridgeKey   = "tenant_id"
	TenantAttrsBridgeKey = "tenant_attrs"
	ABACDataBridgeKey   = "abac_data"
)

// AuthClaims 是 JWT token 中携带的用户声明。
type AuthClaims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// EntryAuthMode 表示 GraphQL 入口鉴权模式（strict/compat）。
type EntryAuthMode string

const (
	EntryAuthModeStrict EntryAuthMode = "strict"
	EntryAuthModeCompat EntryAuthMode = "compat"
)

// EntryAuthOperation 表示 GraphQL 请求入口类型。
type EntryAuthOperation string

const (
	EntryAuthQuery        EntryAuthOperation = "query"
	EntryAuthMutation     EntryAuthOperation = "mutation"
	EntryAuthSubscription EntryAuthOperation = "subscription"
)

// EntryAuthMatrix 定义 query/mutation/subscription 的入口鉴权矩阵。
type EntryAuthMatrix struct {
	Query        EntryAuthMode `json:"query"`
	Mutation     EntryAuthMode `json:"mutation"`
	Subscription EntryAuthMode `json:"subscription"`
}

// EntryAuthPolicy 包含入口鉴权矩阵与公开 query 白名单。
type EntryAuthPolicy struct {
	Matrix               EntryAuthMatrix
	PublicQueryWhitelist map[string]struct{}
	AuditLogger          func(AuthzAuditEntry)
	WarningLogger        func(AuthzAuditEntry)
}

// AuthzReject 表示统一拒绝语义。
type AuthzReject struct {
	Code    string `json:"code"`
	Reason  string `json:"reason"`
	Message string `json:"message"`
}

const (
	AuthzDecisionAllow = "allow"
	AuthzDecisionDeny  = "deny"
	AuthzDecisionWarn  = "warn"
)

// AuthzAuditEntry 表示入口鉴权审计记录（Go/Ash 语义对齐）。
type AuthzAuditEntry struct {
	Timestamp string            `json:"timestamp"`
	Mode      string            `json:"mode"`
	Decision  string            `json:"decision"`
	Code      string            `json:"code"`
	Reason    string            `json:"reason"`
	Message   string            `json:"message"`
	TraceID   string            `json:"trace_id"`
	RequestID string            `json:"request_id"`
	Actor     map[string]string `json:"actor"`
	Tenant    map[string]string `json:"tenant"`
	Action    string            `json:"action"`
	Resource  string            `json:"resource"`
}

func (r *AuthzReject) Error() string {
	if r == nil {
		return "forbidden"
	}
	if strings.TrimSpace(r.Message) == "" {
		return "forbidden"
	}
	return r.Message
}

var queryRootFieldPattern = regexp.MustCompile(`\{\s*(?:[_A-Za-z][_0-9A-Za-z]*\s*:\s*)?([_A-Za-z][_0-9A-Za-z]*)`)

// AuthMiddleware 创建一个 HTTP 中间件，从 Authorization header 中提取并验证 JWT token。
// 验证通过后将 AuthClaims 注入 context；验证失败或无 token 时仍放行请求（由下游决定是否拒绝）。
func AuthMiddleware(signingSecret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := injectTenantContext(r.Context(), r)
			ctx = injectRequestTracingContext(ctx, r)
			header := r.Header.Get("Authorization")
			if !strings.HasPrefix(header, "Bearer ") {
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			tokenStr := strings.TrimPrefix(header, "Bearer ")
			claims := &AuthClaims{}
			token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
				return []byte(signingSecret), nil
			})
			if err != nil || !token.Valid {
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			ctx = context.WithValue(ctx, UserContextKey, claims)
			ctx = injectActorContext(ctx, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// UserFromContext 从 context 中提取已认证的用户声明。
// 如果 context 中没有用户信息，返回 nil。
func UserFromContext(ctx context.Context) *AuthClaims {
	claims, _ := ctx.Value(UserContextKey).(*AuthClaims)
	return claims
}

func injectTenantContext(ctx context.Context, r *http.Request) context.Context {
	tenantID := strings.TrimSpace(r.Header.Get("X-Tenant-ID"))
	if tenantID == "" {
		tenantID = strings.TrimSpace(r.Header.Get("X-Tenant"))
	}
	if tenantID == "" {
		return ctx
	}
	ctx = context.WithValue(ctx, TenantContextKey, tenantID)
	ctx = context.WithValue(ctx, TenantIDBridgeKey, tenantID)
	ctx = context.WithValue(ctx, "tenant.id", tenantID)
	ctx = context.WithValue(ctx, "tenant", tenantID)
	tenantAttrs := map[string]string{
		"id": tenantID,
		"tenant_id": tenantID,
	}
	return context.WithValue(ctx, TenantAttrsBridgeKey, tenantAttrs)
}

func injectRequestTracingContext(ctx context.Context, r *http.Request) context.Context {
	if r == nil {
		return ctx
	}
	requestID := strings.TrimSpace(r.Header.Get("X-Request-ID"))
	if requestID == "" {
		requestID = strings.TrimSpace(r.Header.Get("X-Request-Id"))
	}
	traceID := strings.TrimSpace(r.Header.Get("X-Trace-ID"))
	if traceID == "" {
		traceID = strings.TrimSpace(r.Header.Get("X-B3-TraceId"))
	}
	if requestID != "" {
		ctx = context.WithValue(ctx, "request_id", requestID)
	}
	if traceID != "" {
		ctx = context.WithValue(ctx, "trace_id", traceID)
	}
	if traceID == "" && requestID != "" {
		ctx = context.WithValue(ctx, "trace_id", requestID)
	}
	if requestID == "" && traceID != "" {
		ctx = context.WithValue(ctx, "request_id", traceID)
	}
	return ctx
}

func injectActorContext(ctx context.Context, claims *AuthClaims) context.Context {
	if claims == nil {
		return ctx
	}
	attrs := map[string]string{}
	if strings.TrimSpace(claims.UserID) != "" {
		attrs["id"] = strings.TrimSpace(claims.UserID)
	}
	if strings.TrimSpace(claims.Email) != "" {
		attrs["email"] = strings.TrimSpace(claims.Email)
	}
	if strings.TrimSpace(claims.Role) != "" {
		role := strings.TrimSpace(claims.Role)
		attrs["role"] = role
		ctx = context.WithValue(ctx, ActorRoleBridgeKey, role)
		ctx = context.WithValue(ctx, "actor.role", role)
	}
	if len(attrs) == 0 {
		return ctx
	}
	return context.WithValue(ctx, ActorAttrsBridgeKey, attrs)
}

// TenantIDFromContext 返回当前请求上下文中的 tenant_id。
func TenantIDFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if tenantID, ok := ctx.Value(TenantContextKey).(string); ok && strings.TrimSpace(tenantID) != "" {
		return strings.TrimSpace(tenantID)
	}
	if tenantID, ok := ctx.Value(TenantIDBridgeKey).(string); ok && strings.TrimSpace(tenantID) != "" {
		return strings.TrimSpace(tenantID)
	}
	if tenantID, ok := ctx.Value("tenant").(string); ok && strings.TrimSpace(tenantID) != "" {
		return strings.TrimSpace(tenantID)
	}
	return ""
}

// InjectABACData 向 context 注入 data 字典，供 data.* ABAC 条件匹配。
func InjectABACData(ctx context.Context, attrs map[string]string) context.Context {
	if len(attrs) == 0 {
		return ctx
	}
	normalized := map[string]string{}
	for key, value := range attrs {
		k := strings.TrimSpace(strings.TrimPrefix(key, ":"))
		if k == "" {
			continue
		}
		normalized[k] = strings.TrimSpace(strings.TrimPrefix(value, ":"))
	}
	return context.WithValue(ctx, ABACDataBridgeKey, normalized)
}

// DefaultEntryAuthPolicy 返回入口鉴权默认策略：
// query/subscription 走 compat；mutation 默认 strict，可通过 UNIBO_REQUIRE_ACTOR_FOR_MUTATION 关闭。
func DefaultEntryAuthPolicy() EntryAuthPolicy {
	mutationMode := EntryAuthModeStrict
	if !readBoolEnv("UNIBO_REQUIRE_ACTOR_FOR_MUTATION", true) {
		mutationMode = EntryAuthModeCompat
	}
	return EntryAuthPolicy{
		Matrix: EntryAuthMatrix{
			Query:        EntryAuthModeCompat,
			Mutation:     mutationMode,
			Subscription: EntryAuthModeCompat,
		},
		PublicQueryWhitelist: map[string]struct{}{},
	}
}

// LoadEntryAuthPolicyFromEnv 从环境变量读取 entry_auth_matrix 与公开 query 白名单。
func LoadEntryAuthPolicyFromEnv() EntryAuthPolicy {
	policy := DefaultEntryAuthPolicy()
	policy.Matrix.Query = normalizeEntryAuthMode(os.Getenv("UNIBO_ENTRY_AUTH_QUERY"), policy.Matrix.Query)
	policy.Matrix.Mutation = normalizeEntryAuthMode(os.Getenv("UNIBO_ENTRY_AUTH_MUTATION"), policy.Matrix.Mutation)
	policy.Matrix.Subscription = normalizeEntryAuthMode(os.Getenv("UNIBO_ENTRY_AUTH_SUBSCRIPTION"), policy.Matrix.Subscription)
	policy.PublicQueryWhitelist = parsePublicQueryWhitelist(os.Getenv("UNIBO_PUBLIC_QUERY_WHITELIST"))
	return policy
}

// Authorize 执行 GraphQL 入口鉴权：
// - compat 放行
// - strict + query 命中白名单放行
// - strict + 无 actor 拒绝（统一 FORBIDDEN + reason）
func (p EntryAuthPolicy) Authorize(ctx context.Context, rawQuery string) *AuthzReject {
	operation := detectOperation(rawQuery)
	mode := p.modeFor(operation)
	if mode == EntryAuthModeCompat {
		if UserFromContext(ctx) == nil {
			p.emitAudit(buildAuthzAuditEntry(
				ctx,
				rawQuery,
				mode,
				AuthzDecisionWarn,
				"FORBIDDEN",
				"missing_actor_context",
				"missing actor context (compat warning)",
			))
		} else {
			p.emitAudit(buildAuthzAuditEntry(
				ctx,
				rawQuery,
				mode,
				AuthzDecisionAllow,
				"",
				"",
				"",
			))
		}
		return nil
	}
	if operation == EntryAuthQuery && p.publicQueryWhitelisted(rawQuery) {
		p.emitAudit(buildAuthzAuditEntry(
			ctx,
			rawQuery,
			mode,
			AuthzDecisionAllow,
			"",
			"",
			"",
		))
		return nil
	}
	if UserFromContext(ctx) != nil {
		p.emitAudit(buildAuthzAuditEntry(
			ctx,
			rawQuery,
			mode,
			AuthzDecisionAllow,
			"",
			"",
			"",
		))
		return nil
	}
	reject := &AuthzReject{
		Code:    "FORBIDDEN",
		Reason:  "missing_actor_context",
		Message: "missing actor context",
	}
	p.emitAudit(buildAuthzAuditEntry(
		ctx,
		rawQuery,
		mode,
		AuthzDecisionDeny,
		reject.Code,
		reject.Reason,
		reject.Message,
	))
	return reject
}

func (p EntryAuthPolicy) modeFor(operation EntryAuthOperation) EntryAuthMode {
	switch operation {
	case EntryAuthMutation:
		return p.Matrix.Mutation
	case EntryAuthSubscription:
		return p.Matrix.Subscription
	case EntryAuthQuery:
		return p.Matrix.Query
	default:
		return EntryAuthModeCompat
	}
}

func (p EntryAuthPolicy) publicQueryWhitelisted(rawQuery string) bool {
	fieldName := queryRootField(rawQuery)
	if fieldName == "" {
		return false
	}
	_, ok := p.PublicQueryWhitelist[fieldName]
	return ok
}

func (p EntryAuthPolicy) emitAudit(entry AuthzAuditEntry) {
	if p.AuditLogger != nil {
		p.AuditLogger(entry)
	}
	if entry.Decision == AuthzDecisionWarn && p.WarningLogger != nil {
		p.WarningLogger(entry)
	}
}

func buildAuthzAuditEntry(
	ctx context.Context,
	rawQuery string,
	mode EntryAuthMode,
	decision string,
	code string,
	reason string,
	message string,
) AuthzAuditEntry {
	action := strings.ToLower(string(detectOperation(rawQuery)))
	resource := queryRootField(rawQuery)
	if strings.TrimSpace(resource) == "" {
		resource = action
	}

	requestID := requestIDFromContext(ctx)
	traceID := traceIDFromContext(ctx)
	if requestID == "" && traceID != "" {
		requestID = traceID
	}
	if traceID == "" && requestID != "" {
		traceID = requestID
	}
	if requestID == "" {
		requestID = "no_request_id"
	}
	if traceID == "" {
		traceID = "no_trace_id"
	}

	return AuthzAuditEntry{
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Mode:      strings.ToLower(string(mode)),
		Decision:  normalizeAuditDecision(decision),
		Code:      normalizeAuditCode(decision, code),
		Reason:    normalizeAuditReason(decision, reason),
		Message:   normalizeAuditMessage(decision, reason, message),
		TraceID:   traceID,
		RequestID: requestID,
		Actor:     actorSnapshotFromContext(ctx),
		Tenant:    tenantSnapshotFromContext(ctx),
		Action:    action,
		Resource:  resource,
	}
}

func normalizeAuditDecision(decision string) string {
	normalized := strings.ToLower(strings.TrimSpace(decision))
	switch normalized {
	case AuthzDecisionAllow, AuthzDecisionDeny, AuthzDecisionWarn:
		return normalized
	default:
		return AuthzDecisionAllow
	}
}

func normalizeAuditCode(decision string, code string) string {
	normalized := strings.TrimSpace(code)
	if normalized != "" {
		return normalized
	}
	if normalizeAuditDecision(decision) == AuthzDecisionAllow {
		return "ALLOW"
	}
	return "FORBIDDEN"
}

func normalizeAuditReason(decision string, reason string) string {
	normalized := strings.TrimSpace(reason)
	if normalized != "" {
		return normalized
	}
	if normalizeAuditDecision(decision) == AuthzDecisionAllow {
		return "allowed"
	}
	return "forbidden"
}

func normalizeAuditMessage(decision string, reason string, message string) string {
	normalized := strings.TrimSpace(message)
	if normalized != "" {
		return normalized
	}
	if normalizeAuditDecision(decision) == AuthzDecisionAllow {
		return "allowed"
	}
	return forbiddenMessage(normalizeAuditReason(decision, reason))
}

func requestIDFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	for _, key := range []string{"request_id", "request.id", "x-request-id"} {
		if value := contextString(ctx, key); value != "" {
			return value
		}
	}
	return ""
}

func traceIDFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	for _, key := range []string{"trace_id", "trace.id", "x-trace-id"} {
		if value := contextString(ctx, key); value != "" {
			return value
		}
	}
	return ""
}

func contextString(ctx context.Context, key string) string {
	if ctx == nil {
		return ""
	}
	raw := ctx.Value(key)
	value, ok := raw.(string)
	if !ok {
		return ""
	}
	return strings.TrimSpace(value)
}

func actorSnapshotFromContext(ctx context.Context) map[string]string {
	if ctx == nil {
		return map[string]string{}
	}
	snapshot := map[string]string{}
	claims := UserFromContext(ctx)
	if claims != nil {
		if id := strings.TrimSpace(claims.UserID); id != "" {
			snapshot["id"] = id
		}
		if email := strings.TrimSpace(claims.Email); email != "" {
			snapshot["email"] = email
		}
		if role := strings.TrimSpace(claims.Role); role != "" {
			snapshot["role"] = role
		}
	}

	if attrs, ok := ctx.Value(ActorAttrsBridgeKey).(map[string]string); ok {
		for key, value := range attrs {
			trimmed := strings.TrimSpace(value)
			if trimmed == "" {
				continue
			}
			snapshot[strings.TrimSpace(key)] = trimmed
		}
	}
	if role := contextString(ctx, "actor.role"); role != "" {
		snapshot["role"] = role
	}
	if len(snapshot) == 0 {
		return map[string]string{}
	}
	return snapshot
}

func tenantSnapshotFromContext(ctx context.Context) map[string]string {
	if ctx == nil {
		return map[string]string{}
	}
	snapshot := map[string]string{}
	if tenantID := TenantIDFromContext(ctx); tenantID != "" {
		snapshot["id"] = tenantID
		snapshot["tenant_id"] = tenantID
	}
	if attrs, ok := ctx.Value(TenantAttrsBridgeKey).(map[string]string); ok {
		for key, value := range attrs {
			trimmed := strings.TrimSpace(value)
			if trimmed == "" {
				continue
			}
			snapshot[strings.TrimSpace(key)] = trimmed
		}
	}
	if len(snapshot) == 0 {
		return map[string]string{}
	}
	return snapshot
}

func parsePublicQueryWhitelist(raw string) map[string]struct{} {
	whitelist := map[string]struct{}{}
	for _, item := range strings.Split(raw, ",") {
		fieldName := strings.TrimSpace(item)
		if fieldName == "" {
			continue
		}
		whitelist[fieldName] = struct{}{}
	}
	return whitelist
}

func normalizeEntryAuthMode(raw string, fallback EntryAuthMode) EntryAuthMode {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "strict":
		return EntryAuthModeStrict
	case "compat":
		return EntryAuthModeCompat
	default:
		return fallback
	}
}

func detectOperation(rawQuery string) EntryAuthOperation {
	normalized := strings.ToLower(trimQueryPrefix(rawQuery))
	switch {
	case strings.HasPrefix(normalized, "mutation"):
		return EntryAuthMutation
	case strings.HasPrefix(normalized, "subscription"):
		return EntryAuthSubscription
	default:
		return EntryAuthQuery
	}
}

func trimQueryPrefix(rawQuery string) string {
	lines := strings.Split(rawQuery, "\n")
	kept := make([]string, 0, len(lines))
	skippingPrefix := true
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if skippingPrefix {
			if trimmed == "" || strings.HasPrefix(trimmed, "#") {
				continue
			}
			skippingPrefix = false
		}
		kept = append(kept, line)
	}
	return strings.TrimLeft(strings.Join(kept, "\n"), " \t\r\n")
}

func queryRootField(rawQuery string) string {
	matches := queryRootFieldPattern.FindStringSubmatch(rawQuery)
	if len(matches) == 2 {
		return matches[1]
	}
	return ""
}

func readBoolEnv(key string, fallback bool) bool {
	switch strings.ToLower(strings.TrimSpace(os.Getenv(key))) {
	case "1", "true", "yes", "on":
		return true
	case "0", "false", "no", "off":
		return false
	default:
		return fallback
	}
}

type fieldABACPayload struct {
	Any []fieldABACClause `json:"any"`
}

type fieldABACClause struct {
	Role   string                 `json:"role,omitempty"`
	Actor  map[string]interface{} `json:"actor,omitempty"`
	Data   map[string]interface{} `json:"data,omitempty"`
	Tenant map[string]interface{} `json:"tenant,omitempty"`
}

// EvaluateFieldABAC 评估字段级 ABAC 规则。
// rule 为 JSON 字符串，形如 {"any":[{role,actor,data,tenant}, ...]}。
func EvaluateFieldABAC(ctx context.Context, obj interface{}, rule string) (bool, string, error) {
	trimmed := strings.TrimSpace(rule)
	if trimmed == "" {
		return true, "", nil
	}

	payload := fieldABACPayload{}
	if err := json.Unmarshal([]byte(trimmed), &payload); err != nil {
		single := fieldABACClause{}
		if err2 := json.Unmarshal([]byte(trimmed), &single); err2 != nil {
			return false, "invalid_abac_rule", fmt.Errorf("abac rule json parse failed: %w", err)
		}
		payload.Any = []fieldABACClause{single}
	}
	if len(payload.Any) == 0 {
		return false, "invalid_abac_rule", fmt.Errorf("abac rule requires non-empty any clauses")
	}

	for _, clause := range payload.Any {
		if evaluateABACClause(ctx, obj, clause) {
			return true, "", nil
		}
	}
	return false, "abac_rule_not_satisfied", nil
}

func evaluateABACClause(ctx context.Context, obj interface{}, clause fieldABACClause) bool {
	if role := strings.TrimSpace(clause.Role); role != "" {
		actualRole := actorAttrFromContext(ctx, "role")
		if actualRole == "" || !strings.EqualFold(actualRole, role) {
			return false
		}
	}
	if !matchScopeConditions(clause.Actor, func(key string) string {
		return actorAttrFromContext(ctx, key)
	}) {
		return false
	}
	if !matchScopeConditions(clause.Tenant, func(key string) string {
		return tenantAttrFromContext(ctx, key)
	}) {
		return false
	}
	if !matchScopeConditions(clause.Data, func(key string) string {
		return dataAttrFromObjectOrContext(ctx, obj, key)
	}) {
		return false
	}
	return true
}

func matchScopeConditions(
	conditions map[string]interface{},
	valueResolver func(key string) string,
) bool {
	if len(conditions) == 0 {
		return true
	}
	for key, rawExpected := range conditions {
		actual := valueResolver(key)
		if actual == "" {
			return false
		}
		expected := normalizeExpectedValues(rawExpected)
		if len(expected) == 0 {
			return false
		}
		if !containsString(expected, actual) {
			return false
		}
	}
	return true
}

func normalizeExpectedValues(raw interface{}) []string {
	switch value := raw.(type) {
	case string:
		trimmed := strings.TrimSpace(strings.TrimPrefix(value, ":"))
		if trimmed == "" {
			return nil
		}
		return []string{trimmed}
	case []interface{}:
		result := make([]string, 0, len(value))
		for _, item := range value {
			candidate := strings.TrimSpace(strings.TrimPrefix(fmt.Sprint(item), ":"))
			if candidate == "" {
				continue
			}
			result = append(result, candidate)
		}
		return result
	case []string:
		result := make([]string, 0, len(value))
		for _, item := range value {
			candidate := strings.TrimSpace(strings.TrimPrefix(item, ":"))
			if candidate == "" {
				continue
			}
			result = append(result, candidate)
		}
		return result
	default:
		candidate := strings.TrimSpace(strings.TrimPrefix(fmt.Sprint(value), ":"))
		if candidate == "" {
			return nil
		}
		return []string{candidate}
	}
}

func containsString(values []string, actual string) bool {
	normalized := strings.TrimSpace(strings.TrimPrefix(actual, ":"))
	if normalized == "" {
		return false
	}
	for _, value := range values {
		if strings.EqualFold(strings.TrimSpace(value), normalized) {
			return true
		}
	}
	return false
}

func actorAttrFromContext(ctx context.Context, key string) string {
	normalizedKey := strings.TrimSpace(key)
	if normalizedKey == "" {
		return ""
	}
	if normalizedKey == "role" {
		if role, ok := ctx.Value(ActorRoleBridgeKey).(string); ok && strings.TrimSpace(role) != "" {
			return strings.TrimSpace(role)
		}
	}
	if attrs, ok := ctx.Value(ActorAttrsBridgeKey).(map[string]string); ok {
		for attrKey, attrVal := range attrs {
			if strings.EqualFold(strings.TrimSpace(attrKey), normalizedKey) {
				return strings.TrimSpace(attrVal)
			}
		}
	}
	return ""
}

func tenantAttrFromContext(ctx context.Context, key string) string {
	normalizedKey := strings.TrimSpace(key)
	if normalizedKey == "" {
		return ""
	}
	if strings.EqualFold(normalizedKey, "id") || strings.EqualFold(normalizedKey, "tenant_id") {
		if tenantID := TenantIDFromContext(ctx); tenantID != "" {
			return tenantID
		}
	}
	if attrs, ok := ctx.Value(TenantAttrsBridgeKey).(map[string]string); ok {
		for attrKey, attrVal := range attrs {
			if strings.EqualFold(strings.TrimSpace(attrKey), normalizedKey) {
				return strings.TrimSpace(attrVal)
			}
		}
	}
	return ""
}

func dataAttrFromObjectOrContext(ctx context.Context, obj interface{}, key string) string {
	if value := resolveFieldPath(obj, strings.Split(strings.TrimSpace(key), ".")); value != "" {
		return value
	}
	if attrs, ok := ctx.Value(ABACDataBridgeKey).(map[string]string); ok {
		for attrKey, attrVal := range attrs {
			if strings.EqualFold(strings.TrimSpace(attrKey), strings.TrimSpace(key)) {
				return strings.TrimSpace(attrVal)
			}
		}
	}
	return ""
}

func resolveFieldPath(value interface{}, path []string) string {
	if value == nil || len(path) == 0 {
		return ""
	}
	current := reflect.ValueOf(value)
	for len(path) > 0 {
		for current.IsValid() && current.Kind() == reflect.Ptr {
			if current.IsNil() {
				return ""
			}
			current = current.Elem()
		}
		if !current.IsValid() {
			return ""
		}

		segment := strings.TrimSpace(path[0])
		path = path[1:]
		switch current.Kind() {
		case reflect.Map:
			found := false
			for _, key := range current.MapKeys() {
				if strings.EqualFold(strings.TrimSpace(fmt.Sprint(key.Interface())), segment) {
					current = current.MapIndex(key)
					found = true
					break
				}
			}
			if !found {
				return ""
			}
		case reflect.Struct:
			fieldValue := reflect.Value{}
			fieldType := current.Type()
			for i := 0; i < current.NumField(); i++ {
				sf := fieldType.Field(i)
				jsonTag := strings.Split(sf.Tag.Get("json"), ",")[0]
				if strings.EqualFold(sf.Name, segment) || strings.EqualFold(jsonTag, segment) {
					fieldValue = current.Field(i)
					break
				}
			}
			if !fieldValue.IsValid() {
				return ""
			}
			current = fieldValue
		default:
			if len(path) == 0 {
				return strings.TrimSpace(fmt.Sprint(current.Interface()))
			}
			return ""
		}
	}
	for current.IsValid() && current.Kind() == reflect.Ptr {
		if current.IsNil() {
			return ""
		}
		current = current.Elem()
	}
	if !current.IsValid() {
		return ""
	}
	return strings.TrimSpace(fmt.Sprint(current.Interface()))
}

// NewEntryAuthOperationMiddleware 生成 gqlgen operation middleware，统一执行入口鉴权。
func NewEntryAuthOperationMiddleware(policy EntryAuthPolicy) graphql.OperationMiddleware {
	return func(ctx context.Context, next graphql.OperationHandler) graphql.ResponseHandler {
		opCtx := graphql.GetOperationContext(ctx)
		rawQuery := ""
		if opCtx != nil {
			rawQuery = opCtx.RawQuery
		}
		if reject := policy.Authorize(ctx, rawQuery); reject != nil {
			return func(context.Context) *graphql.Response {
				return &graphql.Response{
					Errors: gqlerror.List{ForbiddenErrorWithMessage(reject.Reason, reject.Message)},
				}
			}
		}
		return next(ctx)
	}
}

// ForbiddenError 构造统一的 FORBIDDEN 错误对象。
func ForbiddenError(reason string) *gqlerror.Error {
	return ForbiddenErrorWithMessage(reason, "")
}

// ForbiddenErrorWithMessage 构造带自定义 message 的 FORBIDDEN 错误对象。
func ForbiddenErrorWithMessage(reason string, message string) *gqlerror.Error {
	normalizedReason := normalizeReason(reason)
	normalizedMessage := strings.TrimSpace(message)
	if normalizedMessage == "" {
		normalizedMessage = forbiddenMessage(normalizedReason)
	}
	return &gqlerror.Error{
		Message: normalizedMessage,
		Extensions: map[string]interface{}{
			"code":   "FORBIDDEN",
			"reason": normalizedReason,
		},
	}
}

// GraphQLErrorPresenter 统一归一化 GraphQL 错误 code/reason 语义。
func GraphQLErrorPresenter(ctx context.Context, err error) *gqlerror.Error {
	gqlErr := graphql.DefaultErrorPresenter(ctx, err)
	if gqlErr == nil {
		gqlErr = &gqlerror.Error{Message: "graphql error"}
	}
	if gqlErr.Extensions == nil {
		gqlErr.Extensions = map[string]interface{}{}
	}
	reason := normalizedErrorReason(gqlErr)
	code := "GRAPHQL_ERROR"
	if isForbiddenReason(reason) {
		code = "FORBIDDEN"
	}
	gqlErr.Extensions["code"] = code
	gqlErr.Extensions["reason"] = reason
	return gqlErr
}

func normalizedErrorReason(err *gqlerror.Error) string {
	if err == nil {
		return "graphql_error"
	}

	if err.Extensions != nil {
		reason := normalizeReason(err.Extensions["reason"])
		if shouldPreserveReason(reason) {
			return reason
		}
		code, _ := err.Extensions["code"].(string)
		switch strings.ToUpper(strings.TrimSpace(code)) {
		case "FORBIDDEN", "UNAUTHORIZED":
			return "forbidden"
		}
	}

	message := strings.ToLower(strings.TrimSpace(err.Message))
	switch {
	case strings.Contains(message, "missing actor context"):
		return "missing_actor_context"
	case strings.Contains(message, "insufficient permissions"):
		return "insufficient_role"
	case strings.Contains(message, "abac rule"):
		return "invalid_abac_rule"
	case strings.Contains(message, "unsupported op"):
		return "unsupported_postprocess_op"
	case strings.Contains(message, "forbidden"):
		return "forbidden"
	case strings.Contains(message, "unauthorized"):
		return "unauthorized"
	default:
		return "graphql_error"
	}
}

func normalizeReason(reason interface{}) string {
	switch value := reason.(type) {
	case string:
		trimmed := strings.TrimSpace(value)
		if trimmed == "" {
			return "forbidden"
		}
		return trimmed
	default:
		return "forbidden"
	}
}

func shouldPreserveReason(reason string) bool {
	switch reason {
	case "invalid_abac_rule", "unsupported_postprocess_op":
		return true
	default:
		return isForbiddenReason(reason)
	}
}

func isForbiddenReason(reason string) bool {
	switch reason {
	case "forbidden", "unauthorized", "missing_actor_context", "insufficient_role", "abac_rule_not_satisfied":
		return true
	default:
		return false
	}
}

func forbiddenMessage(reason string) string {
	if reason == "missing_actor_context" {
		return "missing actor context"
	}
	return "forbidden"
}
