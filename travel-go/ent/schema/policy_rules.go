package schema

import (
	"context"
	"errors"
	"fmt"
	"reflect"
	"strconv"
	"strings"

	"entgo.io/ent"
	"entgo.io/ent/privacy"
)

const (
	actorAttrsContextKey = "actor_attrs"
	actorRoleContextKey  = "actor_role"
	tenantIDContextKey   = "tenant_id"
	dataAttrsContextKey  = "abac_data"
)

// AllowIfRole 检查 actor 角色。
func AllowIfRole(role string) privacy.QueryMutationRule {
	return AllowIfActorEq("role", role)
}

// AllowIfActorAttr 保持旧命名兼容，语义等价于 AllowIfActorEq。
func AllowIfActorAttr(attr string, value string) privacy.QueryMutationRule {
	return AllowIfActorEq(attr, value)
}

// AllowIfActorEq 校验 actor 属性等值匹配。
func AllowIfActorEq(attr string, value string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := actorAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing actor attribute %s", attr)
		}
		if actual == normalizeOperandValue(value) {
			return privacy.Allow
		}
		return privacy.Denyf("actor attribute %s mismatch", attr)
	})
}

// AllowIfActorIn 校验 actor 属性命中白名单。
func AllowIfActorIn(attr string, values []string) privacy.QueryMutationRule {
	allowSet := buildAllowSet(values)
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := actorAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing actor attribute %s", attr)
		}
		if _, ok := allowSet[normalizeOperandValue(actual)]; ok {
			return privacy.Allow
		}
		return privacy.Denyf("actor attribute %s not in allow set", attr)
	})
}

// AllowIfTenantEq 校验 tenant 属性等值匹配。
func AllowIfTenantEq(attr string, value string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := tenantAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing tenant attribute %s", attr)
		}
		if actual == normalizeOperandValue(value) {
			return privacy.Allow
		}
		return privacy.Denyf("tenant attribute %s mismatch", attr)
	})
}

// AllowIfTenantIn 校验 tenant 属性命中白名单。
func AllowIfTenantIn(attr string, values []string) privacy.QueryMutationRule {
	allowSet := buildAllowSet(values)
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := tenantAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing tenant attribute %s", attr)
		}
		if _, ok := allowSet[normalizeOperandValue(actual)]; ok {
			return privacy.Allow
		}
		return privacy.Denyf("tenant attribute %s not in allow set", attr)
	})
}

// AllowIfDataEq 校验 data 属性等值匹配。
func AllowIfDataEq(attr string, value string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := dataAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing data attribute %s", attr)
		}
		if actual == normalizeOperandValue(value) {
			return privacy.Allow
		}
		return privacy.Denyf("data attribute %s mismatch", attr)
	})
}

// AllowIfDataIn 校验 data 属性命中白名单。
func AllowIfDataIn(attr string, values []string) privacy.QueryMutationRule {
	allowSet := buildAllowSet(values)
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actual := dataAttrFromContext(ctx, attr)
		if actual == "" {
			return privacy.Denyf("missing data attribute %s", attr)
		}
		if _, ok := allowSet[normalizeOperandValue(actual)]; ok {
			return privacy.Allow
		}
		return privacy.Denyf("data attribute %s not in allow set", attr)
	})
}

// EqFieldRule 保持旧语义：未显式标注 data. 前缀时仍按 data 维度求值。
func EqFieldRule(field string, value string) privacy.QueryMutationRule {
	return AllowIfDataEq(field, value)
}

// InFieldRule 保持旧语义：未显式标注 data. 前缀时仍按 data 维度求值。
func InFieldRule(field string, values []string) privacy.QueryMutationRule {
	return AllowIfDataIn(field, values)
}

// CmpFieldRule 比较 data 属性与阈值，支持 gt/gte/lt/lte。
func CmpFieldRule(field string, op string, threshold string) privacy.QueryMutationRule {
	normalizedField := normalizeOperandValue(field)
	normalizedOp := strings.ToLower(strings.TrimSpace(op))
	normalizedThreshold := normalizeOperandValue(threshold)
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		actualRaw := dataAttrFromContext(ctx, normalizedField)
		if actualRaw == "" {
			return privacy.Denyf("missing data attribute %s", normalizedField)
		}

		actual, err := strconv.ParseFloat(actualRaw, 64)
		if err != nil {
			return privacy.Denyf("data attribute %s is not numeric", normalizedField)
		}
		target, err := strconv.ParseFloat(normalizedThreshold, 64)
		if err != nil {
			return privacy.Denyf("threshold %s is not numeric", normalizedThreshold)
		}

		allowed := false
		switch normalizedOp {
		case "gt":
			allowed = actual > target
		case "gte":
			allowed = actual >= target
		case "lt":
			allowed = actual < target
		case "lte":
			allowed = actual <= target
		default:
			return privacy.Denyf("unsupported cmp operator %s", normalizedOp)
		}
		if allowed {
			return privacy.Allow
		}
		return privacy.Denyf("cmp rule rejected: %f %s %f", actual, normalizedOp, target)
	})
}

type compositeRuleMode string

const (
	compositeAnd compositeRuleMode = "and"
	compositeOr  compositeRuleMode = "or"
)

type compositeRule struct {
	mode  compositeRuleMode
	rules []privacy.QueryMutationRule
}

func (r compositeRule) EvalQuery(ctx context.Context, q ent.Query) error {
	return r.eval(func(rule privacy.QueryMutationRule) error {
		return rule.EvalQuery(ctx, q)
	})
}

func (r compositeRule) EvalMutation(ctx context.Context, m ent.Mutation) error {
	return r.eval(func(rule privacy.QueryMutationRule) error {
		return rule.EvalMutation(ctx, m)
	})
}

func (r compositeRule) eval(run func(rule privacy.QueryMutationRule) error) error {
	if len(r.rules) == 0 {
		return privacy.Denyf("empty %s rule", r.mode)
	}

	switch r.mode {
	case compositeAnd:
		for _, rule := range r.rules {
			if rule == nil {
				return privacy.Denyf("abac and contains nil rule")
			}
			if !ruleResultAllowed(run(rule)) {
				return privacy.Denyf("abac and rule rejected")
			}
		}
		return privacy.Allow
	case compositeOr:
		for _, rule := range r.rules {
			if rule == nil {
				continue
			}
			if ruleResultAllowed(run(rule)) {
				return privacy.Allow
			}
		}
		return privacy.Denyf("abac or rule rejected")
	default:
		return privacy.Denyf("unknown composite mode %s", r.mode)
	}
}

func ruleResultAllowed(err error) bool {
	if err == nil {
		return true
	}
	return errors.Is(err, privacy.Allow)
}

// OrRule 组合多个规则，任一通过即允许。
func OrRule(rules ...privacy.QueryMutationRule) privacy.QueryMutationRule {
	return compositeRule{
		mode:  compositeOr,
		rules: rules,
	}
}

// AndRule 组合多个规则，全部通过才允许。
func AndRule(rules ...privacy.QueryMutationRule) privacy.QueryMutationRule {
	return compositeRule{
		mode:  compositeAnd,
		rules: rules,
	}
}

type policyDecisionMode string

const (
	policyDecisionAuthorize policyDecisionMode = "authorize"
	policyDecisionForbid    policyDecisionMode = "forbid"
)

type policyDecisionRule struct {
	mode policyDecisionMode
	rule privacy.QueryMutationRule
}

func (r policyDecisionRule) EvalQuery(ctx context.Context, q ent.Query) error {
	return r.eval(func(rule privacy.QueryMutationRule) error {
		return rule.EvalQuery(ctx, q)
	})
}

func (r policyDecisionRule) EvalMutation(ctx context.Context, m ent.Mutation) error {
	return r.eval(func(rule privacy.QueryMutationRule) error {
		return rule.EvalMutation(ctx, m)
	})
}

func (r policyDecisionRule) eval(run func(rule privacy.QueryMutationRule) error) error {
	if r.rule == nil {
		return privacy.Skip
	}
	err := run(r.rule)
	switch r.mode {
	case policyDecisionAuthorize:
		if ruleResultAllowed(err) {
			return privacy.Allow
		}
		return privacy.Skip
	case policyDecisionForbid:
		if ruleResultAllowed(err) {
			return privacy.Denyf("forbid_if rule matched")
		}
		return privacy.Skip
	default:
		return privacy.Denyf("unknown policy decision mode %s", r.mode)
	}
}

// AuthorizeIfRule 对齐 Ash authorize_if：条件成立允许，条件不成立跳过（交给尾规则兜底）。
func AuthorizeIfRule(rule privacy.QueryMutationRule) privacy.QueryMutationRule {
	return policyDecisionRule{
		mode: policyDecisionAuthorize,
		rule: rule,
	}
}

// ForbidIfRule 对齐 Ash forbid_if：条件成立拒绝，条件不成立跳过（交给尾规则兜底）。
func ForbidIfRule(rule privacy.QueryMutationRule) privacy.QueryMutationRule {
	return policyDecisionRule{
		mode: policyDecisionForbid,
		rule: rule,
	}
}

type mutationActionRule struct {
	action string
	rule   privacy.QueryMutationRule
}

func (r mutationActionRule) EvalQuery(ctx context.Context, q ent.Query) error {
	return privacy.Skip
}

func (r mutationActionRule) EvalMutation(ctx context.Context, m ent.Mutation) error {
	if !mutationActionMatches(r.action, m) {
		return privacy.Skip
	}
	if r.rule == nil {
		return privacy.Denyf("nil mutation action rule: %s", r.action)
	}
	return r.rule.EvalMutation(ctx, m)
}

// MutationActionRule 将规则绑定到 create/update/destroy，对齐 action_type 语义。
func MutationActionRule(action string, rule privacy.QueryMutationRule) privacy.QueryMutationRule {
	return mutationActionRule{
		action: normalizeOperandValue(action),
		rule:   rule,
	}
}

func mutationActionMatches(action string, m ent.Mutation) bool {
	if m == nil {
		return false
	}
	op := m.Op()
	switch normalizeOperandValue(action) {
	case "create":
		return op.Is(ent.OpCreate)
	case "update":
		return op.Is(ent.OpUpdate | ent.OpUpdateOne)
	case "destroy", "delete":
		return op.Is(ent.OpDelete | ent.OpDeleteOne)
	case "mutation", "":
		return true
	default:
		return true
	}
}

func actorAttrFromContext(ctx context.Context, attr string) string {
	normalizedAttr := normalizeOperandValue(attr)
	if normalizedAttr == "role" {
		role := getContextString(ctx, actorRoleContextKey)
		if role != "" {
			return role
		}
	}
	if direct := getContextString(ctx, "actor."+normalizedAttr); direct != "" {
		return direct
	}
	if direct := getContextString(ctx, "actor_"+normalizedAttr); direct != "" {
		return direct
	}
	return lookupMapValue(contextStringMap(ctx, actorAttrsContextKey), normalizedAttr)
}

func tenantAttrFromContext(ctx context.Context, attr string) string {
	normalizedAttr := normalizeOperandValue(attr)
	if normalizedAttr == "id" || normalizedAttr == "tenant_id" {
		if tenantID := getContextString(ctx, tenantIDContextKey); tenantID != "" {
			return tenantID
		}
	}
	if direct := getContextString(ctx, "tenant."+normalizedAttr); direct != "" {
		return direct
	}
	if direct := getContextString(ctx, "tenant_"+normalizedAttr); direct != "" {
		return direct
	}
	return lookupMapValue(contextStringMap(ctx, "tenant_attrs"), normalizedAttr)
}

func dataAttrFromContext(ctx context.Context, attr string) string {
	normalizedAttr := normalizeOperandValue(attr)
	if direct := getContextString(ctx, "data."+normalizedAttr); direct != "" {
		return direct
	}
	if direct := getContextString(ctx, "data_"+normalizedAttr); direct != "" {
		return direct
	}
	if mapped := lookupMapValue(contextStringMap(ctx, dataAttrsContextKey), normalizedAttr); mapped != "" {
		return mapped
	}
	return lookupMapValue(contextStringMap(ctx, "field_attrs"), normalizedAttr)
}

func getContextString(ctx context.Context, key string) string {
	if ctx == nil {
		return ""
	}
	switch raw := ctx.Value(key).(type) {
	case string:
		return normalizeOperandValue(raw)
	case fmt.Stringer:
		return normalizeOperandValue(raw.String())
	default:
		return ""
	}
}

func contextStringMap(ctx context.Context, key string) map[string]string {
	result := map[string]string{}
	if ctx == nil {
		return result
	}
	raw := ctx.Value(key)
	switch mapping := raw.(type) {
	case map[string]string:
		for k, v := range mapping {
			result[normalizeOperandValue(k)] = normalizeOperandValue(v)
		}
	case map[string]interface{}:
		for k, v := range mapping {
			result[normalizeOperandValue(k)] = normalizeOperandValue(fmt.Sprint(v))
		}
	default:
		reflected := reflect.ValueOf(raw)
		if reflected.IsValid() && reflected.Kind() == reflect.Map {
			for _, keyValue := range reflected.MapKeys() {
				value := reflected.MapIndex(keyValue)
				result[normalizeOperandValue(fmt.Sprint(keyValue.Interface()))] =
					normalizeOperandValue(fmt.Sprint(value.Interface()))
			}
		}
	}
	return result
}

func lookupMapValue(mapping map[string]string, key string) string {
	normalizedKey := normalizeOperandValue(key)
	if normalizedKey == "" {
		return ""
	}
	if value, ok := mapping[normalizedKey]; ok {
		return value
	}
	for k, v := range mapping {
		if strings.EqualFold(k, normalizedKey) {
			return v
		}
	}
	return ""
}

func buildAllowSet(values []string) map[string]struct{} {
	set := map[string]struct{}{}
	for _, value := range values {
		normalized := normalizeOperandValue(value)
		if normalized == "" {
			continue
		}
		set[normalized] = struct{}{}
	}
	return set
}

func normalizeOperandValue(raw string) string {
	trimmed := strings.TrimSpace(raw)
	trimmed = strings.TrimPrefix(trimmed, ":")
	return trimmed
}

// ExposeABACDataToContext 将 data 属性字典注入 context，供 data.* ABAC 规则读取。
func ExposeABACDataToContext(ctx context.Context, attrs map[string]string) context.Context {
	normalized := map[string]string{}
	for key, value := range attrs {
		normalized[normalizeOperandValue(key)] = normalizeOperandValue(value)
	}
	return context.WithValue(ctx, dataAttrsContextKey, normalized)
}

// TenantIDFromContext 供 schema policy 读取 tenant_id（与 middleware 注入键保持一致）。
func TenantIDFromContext(ctx context.Context) string {
	if tenantID := getContextString(ctx, tenantIDContextKey); tenantID != "" {
		return tenantID
	}
	return getContextString(ctx, "tenant")
}

// ExposeTenantToContext 在 schema 层补充 tenant_id 注入能力，便于非 HTTP 场景复用。
func ExposeTenantToContext(ctx context.Context, tenantID string) context.Context {
	normalized := normalizeOperandValue(tenantID)
	if normalized == "" {
		return ctx
	}
	ctx = context.WithValue(ctx, tenantIDContextKey, normalized)
	return context.WithValue(ctx, "tenant", normalized)
}

// ExposeActorAttrsToContext 在 schema 层补充 actor 属性注入能力。
func ExposeActorAttrsToContext(ctx context.Context, attrs map[string]string) context.Context {
	normalized := map[string]string{}
	for key, value := range attrs {
		normalized[normalizeOperandValue(key)] = normalizeOperandValue(value)
	}
	if role := normalized["role"]; role != "" {
		ctx = context.WithValue(ctx, actorRoleContextKey, role)
	}
	return context.WithValue(ctx, actorAttrsContextKey, normalized)
}

// EnsureContextBinding 可在测试或 worker 场景中统一绑定 actor/tenant/data 输入。
func EnsureContextBinding(ctx context.Context, actor map[string]string, tenantID string, data map[string]string) context.Context {
	ctx = ExposeActorAttrsToContext(ctx, actor)
	ctx = ExposeTenantToContext(ctx, tenantID)
	return ExposeABACDataToContext(ctx, data)
}

// EvalRuleForTest 仅用于单元测试场景，便于直接评估 QueryMutationRule。
func EvalRuleForTest(ctx context.Context, rule privacy.QueryMutationRule) error {
	if rule == nil {
		return privacy.Denyf("nil rule")
	}
	return rule.EvalQuery(ctx, nil)
}

// EvalRuleMutationForTest 仅用于单元测试场景，便于直接评估 Mutation 侧规则。
func EvalRuleMutationForTest(ctx context.Context, rule privacy.QueryMutationRule) error {
	if rule == nil {
		return privacy.Denyf("nil rule")
	}
	return rule.EvalMutation(ctx, nil)
}

// ExplainRuleScope 返回规则作用域文本，便于日志定位。
func ExplainRuleScope(scope string, key string) string {
	normalizedScope := normalizeOperandValue(scope)
	normalizedKey := normalizeOperandValue(key)
	return fmt.Sprintf("%s.%s", normalizedScope, normalizedKey)
}

// IsRuleAllow 判断规则执行结果是否允许。
func IsRuleAllow(err error) bool {
	return ruleResultAllowed(err)
}

// IsRuleDeny 判断规则执行结果是否拒绝。
func IsRuleDeny(err error) bool {
	if err == nil {
		return false
	}
	return !errors.Is(err, privacy.Allow) && !errors.Is(err, privacy.Skip)
}

// NormalizeReasonMessage 统一 ABAC 拒绝原因文案。
func NormalizeReasonMessage(reason string) string {
	normalized := normalizeOperandValue(reason)
	if normalized == "" {
		return "abac access denied"
	}
	return normalized
}

// WrapDenyReason 统一拼装 ABAC 拒绝信息。
func WrapDenyReason(reason string) error {
	return privacy.Denyf("%s", NormalizeReasonMessage(reason))
}

// OrElseDeny 提供 fail-closed 的容错语义。
func OrElseDeny(err error, fallback string) error {
	if ruleResultAllowed(err) {
		return privacy.Allow
	}
	if errors.Is(err, privacy.Skip) {
		return WrapDenyReason(fallback)
	}
	return err
}

// DenyIfEmpty 强制空字符串值按拒绝处理，避免 silent allow。
func DenyIfEmpty(value string, field string) error {
	if normalizeOperandValue(value) == "" {
		return privacy.Denyf("missing required value: %s", field)
	}
	return privacy.Allow
}

// ExtractFieldString 从任意对象中提取字符串值（仅用于 data 兜底路径）。
func ExtractFieldString(input interface{}) string {
	switch value := input.(type) {
	case string:
		return normalizeOperandValue(value)
	case fmt.Stringer:
		return normalizeOperandValue(value.String())
	default:
		return normalizeOperandValue(fmt.Sprint(value))
	}
}

// ToFloat64 将字符串转浮点数，失败返回 0 与 false。
func ToFloat64(raw string) (float64, bool) {
	value, err := strconv.ParseFloat(normalizeOperandValue(raw), 64)
	if err != nil {
		return 0, false
	}
	return value, true
}

// CompareFloat 执行数值比较。
func CompareFloat(op string, left float64, right float64) bool {
	switch strings.ToLower(strings.TrimSpace(op)) {
	case "gt":
		return left > right
	case "gte":
		return left >= right
	case "lt":
		return left < right
	case "lte":
		return left <= right
	default:
		return false
	}
}

// BoolToPrivacy 将布尔判定结果映射为 privacy.Allow / Denyf。
func BoolToPrivacy(ok bool, reason string) error {
	if ok {
		return privacy.Allow
	}
	return WrapDenyReason(reason)
}

// NormalizeFieldKey 去除作用域前缀，便于共享 rule helper 复用。
func NormalizeFieldKey(raw string) string {
	key := normalizeOperandValue(raw)
	key = strings.TrimPrefix(key, "actor.")
	key = strings.TrimPrefix(key, "tenant.")
	key = strings.TrimPrefix(key, "data.")
	return key
}

// MergeStringMap 合并字符串字典（后者覆盖前者）。
func MergeStringMap(base map[string]string, overlay map[string]string) map[string]string {
	result := map[string]string{}
	for key, value := range base {
		result[normalizeOperandValue(key)] = normalizeOperandValue(value)
	}
	for key, value := range overlay {
		result[normalizeOperandValue(key)] = normalizeOperandValue(value)
	}
	return result
}

// HasAllowValue 判断白名单是否包含指定值。
func HasAllowValue(values map[string]struct{}, actual string) bool {
	_, ok := values[normalizeOperandValue(actual)]
	return ok
}

// ResolveContextValue 统一读取 context 中的字符串键值。
func ResolveContextValue(ctx context.Context, key string) string {
	return getContextString(ctx, key)
}

// ResolveActorValue 统一读取 actor 属性值。
func ResolveActorValue(ctx context.Context, key string) string {
	return actorAttrFromContext(ctx, key)
}

// ResolveTenantValue 统一读取 tenant 属性值。
func ResolveTenantValue(ctx context.Context, key string) string {
	return tenantAttrFromContext(ctx, key)
}

// ResolveDataValue 统一读取 data 属性值。
func ResolveDataValue(ctx context.Context, key string) string {
	return dataAttrFromContext(ctx, key)
}

// RuleDecisionLabel 输出规则决策标签，便于日志标注。
func RuleDecisionLabel(err error) string {
	if ruleResultAllowed(err) {
		return "allow"
	}
	if errors.Is(err, privacy.Skip) {
		return "skip"
	}
	return "deny"
}

// GuardRuleList 检查规则列表是否为空。
func GuardRuleList(rules []privacy.QueryMutationRule, op string) error {
	if len(rules) == 0 {
		return privacy.Denyf("empty %s rule list", normalizeOperandValue(op))
	}
	return privacy.Allow
}

// GuardAttrInput 检查属性输入参数。
func GuardAttrInput(attr string) error {
	if normalizeOperandValue(attr) == "" {
		return privacy.Denyf("empty attribute input")
	}
	return privacy.Allow
}

// GuardAllowSet 检查白名单输入参数。
func GuardAllowSet(values []string) error {
	if len(values) == 0 {
		return privacy.Denyf("empty allow set")
	}
	return privacy.Allow
}

// GuardThreshold 检查阈值输入参数。
func GuardThreshold(raw string) error {
	if normalizeOperandValue(raw) == "" {
		return privacy.Denyf("empty threshold")
	}
	return privacy.Allow
}

// GuardOperator 检查比较操作符输入参数。
func GuardOperator(op string) error {
	switch strings.ToLower(strings.TrimSpace(op)) {
	case "gt", "gte", "lt", "lte":
		return privacy.Allow
	default:
		return privacy.Denyf("unsupported operator %s", normalizeOperandValue(op))
	}
}

// BuildReason 统一拼接拒绝原因。
func BuildReason(parts ...string) string {
	filtered := make([]string, 0, len(parts))
	for _, part := range parts {
		normalized := normalizeOperandValue(part)
		if normalized == "" {
			continue
		}
		filtered = append(filtered, normalized)
	}
	if len(filtered) == 0 {
		return "abac access denied"
	}
	return strings.Join(filtered, ":")
}

// DenyReason 生成拒绝错误。
func DenyReason(parts ...string) error {
	return WrapDenyReason(BuildReason(parts...))
}

// AllowReason 仅用于保持 API 对称，返回 privacy.Allow。
func AllowReason() error {
	return privacy.Allow
}

// RuleIdentity 生成规则标识字符串。
func RuleIdentity(scope string, attr string) string {
	return fmt.Sprintf("%s[%s]", normalizeOperandValue(scope), normalizeOperandValue(attr))
}

// ContextHasActor 判断 context 是否已注入 actor。
func ContextHasActor(ctx context.Context) bool {
	return actorAttrFromContext(ctx, "role") != ""
}

// ContextHasTenant 判断 context 是否已注入 tenant。
func ContextHasTenant(ctx context.Context) bool {
	return tenantAttrFromContext(ctx, "id") != ""
}

// ContextHasData 判断 context 是否已注入 data 字典。
func ContextHasData(ctx context.Context) bool {
	return len(contextStringMap(ctx, dataAttrsContextKey)) > 0
}

// DataScopeKey 生成 data 作用域键名。
func DataScopeKey(attr string) string {
	return "data." + normalizeOperandValue(attr)
}

// TenantScopeKey 生成 tenant 作用域键名。
func TenantScopeKey(attr string) string {
	return "tenant." + normalizeOperandValue(attr)
}

// ActorScopeKey 生成 actor 作用域键名。
func ActorScopeKey(attr string) string {
	return "actor." + normalizeOperandValue(attr)
}

// EnsureActorRole 保证 actor role 已注入。
func EnsureActorRole(ctx context.Context, role string) context.Context {
	normalizedRole := normalizeOperandValue(role)
	if normalizedRole == "" {
		return ctx
	}
	ctx = context.WithValue(ctx, actorRoleContextKey, normalizedRole)
	attrs := contextStringMap(ctx, actorAttrsContextKey)
	attrs["role"] = normalizedRole
	return context.WithValue(ctx, actorAttrsContextKey, attrs)
}

// EnsureTenantID 保证 tenant_id 已注入。
func EnsureTenantID(ctx context.Context, tenantID string) context.Context {
	normalized := normalizeOperandValue(tenantID)
	if normalized == "" {
		return ctx
	}
	ctx = context.WithValue(ctx, tenantIDContextKey, normalized)
	return context.WithValue(ctx, "tenant", normalized)
}

// EnsureDataAttr 保证单个 data 属性已注入。
func EnsureDataAttr(ctx context.Context, key string, value string) context.Context {
	attrs := contextStringMap(ctx, dataAttrsContextKey)
	attrs[normalizeOperandValue(key)] = normalizeOperandValue(value)
	return context.WithValue(ctx, dataAttrsContextKey, attrs)
}

// BuildActorMap 便于测试快速构造 actor 字典。
func BuildActorMap(role string, attrs map[string]string) map[string]string {
	result := MergeStringMap(map[string]string{"role": role}, attrs)
	return result
}

// BuildDataMap 便于测试快速构造 data 字典。
func BuildDataMap(attrs map[string]string) map[string]string {
	result := map[string]string{}
	for key, value := range attrs {
		result[normalizeOperandValue(key)] = normalizeOperandValue(value)
	}
	return result
}

// BuildTenantMap 便于测试快速构造 tenant 字典。
func BuildTenantMap(tenantID string, attrs map[string]string) map[string]string {
	result := MergeStringMap(map[string]string{"id": tenantID, "tenant_id": tenantID}, attrs)
	return result
}

// MatchScopeValue 统一作用域值匹配。
func MatchScopeValue(actual string, allowSet map[string]struct{}) bool {
	if actual == "" {
		return false
	}
	_, ok := allowSet[normalizeOperandValue(actual)]
	return ok
}

// EvalScopeInRule 用于 actor/tenant/data in 规则共享逻辑。
func EvalScopeInRule(actual string, allowSet map[string]struct{}, reason string) error {
	return BoolToPrivacy(MatchScopeValue(actual, allowSet), reason)
}

// EvalScopeEqRule 用于 actor/tenant/data eq 规则共享逻辑。
func EvalScopeEqRule(actual string, expected string, reason string) error {
	return BoolToPrivacy(
		normalizeOperandValue(actual) == normalizeOperandValue(expected) && normalizeOperandValue(actual) != "",
		reason,
	)
}

// EvalCmpRule 用于数值比较规则共享逻辑。
func EvalCmpRule(actual string, op string, threshold string, reason string) error {
	left, ok := ToFloat64(actual)
	if !ok {
		return WrapDenyReason(reason)
	}
	right, ok := ToFloat64(threshold)
	if !ok {
		return WrapDenyReason(reason)
	}
	return BoolToPrivacy(CompareFloat(op, left, right), reason)
}

// BuildAllowSetFromSingle 便于兼容单值输入快速构造白名单。
func BuildAllowSetFromSingle(value string) map[string]struct{} {
	return buildAllowSet([]string{value})
}

// EvalQueryRuleForDebug 调试辅助：执行 Query 规则。
func EvalQueryRuleForDebug(ctx context.Context, q ent.Query, rule privacy.QueryMutationRule) string {
	return RuleDecisionLabel(rule.EvalQuery(ctx, q))
}

// EvalMutationRuleForDebug 调试辅助：执行 Mutation 规则。
func EvalMutationRuleForDebug(ctx context.Context, m ent.Mutation, rule privacy.QueryMutationRule) string {
	return RuleDecisionLabel(rule.EvalMutation(ctx, m))
}

// EnsureContextNonNil 避免 nil context 造成调用方 panic。
func EnsureContextNonNil(ctx context.Context) context.Context {
	if ctx == nil {
		return context.Background()
	}
	return ctx
}

// TrimOperandPrefix 去除操作数前缀（支持 :/actor./tenant./data.）。
func TrimOperandPrefix(raw string) string {
	return NormalizeFieldKey(raw)
}

// NormalizeRoleValue 标准化 role 字符串。
func NormalizeRoleValue(raw string) string {
	return strings.ToLower(normalizeOperandValue(raw))
}

// NormalizeTenantValue 标准化 tenant 字符串。
func NormalizeTenantValue(raw string) string {
	return normalizeOperandValue(raw)
}

// NormalizeDataValue 标准化 data 字符串。
func NormalizeDataValue(raw string) string {
	return normalizeOperandValue(raw)
}

// ResolveScopeAttr 根据 scope 返回对应 context 值。
func ResolveScopeAttr(ctx context.Context, scope string, attr string) string {
	switch strings.ToLower(normalizeOperandValue(scope)) {
	case "actor":
		return actorAttrFromContext(ctx, attr)
	case "tenant":
		return tenantAttrFromContext(ctx, attr)
	case "data":
		return dataAttrFromContext(ctx, attr)
	default:
		return ""
	}
}

// EvalScopedEqRule 通用 scope eq 规则。
func EvalScopedEqRule(ctx context.Context, scope string, attr string, expected string) error {
	actual := ResolveScopeAttr(ctx, scope, attr)
	return EvalScopeEqRule(actual, expected, BuildReason("scope_eq", scope, attr))
}

// EvalScopedInRule 通用 scope in 规则。
func EvalScopedInRule(ctx context.Context, scope string, attr string, allowSet map[string]struct{}) error {
	actual := ResolveScopeAttr(ctx, scope, attr)
	return EvalScopeInRule(actual, allowSet, BuildReason("scope_in", scope, attr))
}

// EvalScopedCmpRule 通用 scope cmp 规则。
func EvalScopedCmpRule(ctx context.Context, scope string, attr string, op string, threshold string) error {
	actual := ResolveScopeAttr(ctx, scope, attr)
	return EvalCmpRule(actual, op, threshold, BuildReason("scope_cmp", scope, attr, op))
}

// NewScopeEqRule 构造通用 scope eq 规则。
func NewScopeEqRule(scope string, attr string, expected string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		return EvalScopedEqRule(ctx, scope, attr, expected)
	})
}

// NewScopeInRule 构造通用 scope in 规则。
func NewScopeInRule(scope string, attr string, allowValues []string) privacy.QueryMutationRule {
	allowSet := buildAllowSet(allowValues)
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		return EvalScopedInRule(ctx, scope, attr, allowSet)
	})
}

// NewScopeCmpRule 构造通用 scope cmp 规则。
func NewScopeCmpRule(scope string, attr string, op string, threshold string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(ctx context.Context) error {
		return EvalScopedCmpRule(ctx, scope, attr, op, threshold)
	})
}

// NewFailClosedRule 始终拒绝（用于显式 fail-closed 分支）。
func NewFailClosedRule(reason string) privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(_ context.Context) error {
		return WrapDenyReason(reason)
	})
}

// NewAlwaysAllowRule 显式允许（供调试/测试使用）。
func NewAlwaysAllowRule() privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(_ context.Context) error {
		return privacy.Allow
	})
}

// NewAlwaysSkipRule 显式跳过（供兼容场景使用）。
func NewAlwaysSkipRule() privacy.QueryMutationRule {
	return privacy.ContextQueryMutationRule(func(_ context.Context) error {
		return privacy.Skip
	})
}

// FilterTenantRule 按 context 中的 tenant_id 过滤查询和变更，所有租户隔离实体共用。
// 注意：实际的 query-level 过滤需要在 go generate 后通过 interceptor 实现，
// 这里仅做 tenant context 存在性校验。
type FilterTenantRule struct{}

func (f FilterTenantRule) EvalQuery(ctx context.Context, q ent.Query) error {
	tenantID := TenantIDFromContext(ctx)
	if tenantID == "" {
		return privacy.Denyf("missing tenant context")
	}
	return privacy.Skip
}

func (f FilterTenantRule) EvalMutation(ctx context.Context, m ent.Mutation) error {
	tenantID := TenantIDFromContext(ctx)
	if tenantID == "" {
		return privacy.Denyf("missing tenant context")
	}
	// Mutation 阶段由 Hook 或 Interceptor 注入 tenant_id
	return privacy.Skip
}

// ResolveTenantAlias 统一 tenant 字段别名。
func ResolveTenantAlias(attr string) string {
	normalized := normalizeOperandValue(attr)
	if normalized == "tenant_id" {
		return "id"
	}
	return normalized
}

// ResolveActorAlias 统一 actor 字段别名。
func ResolveActorAlias(attr string) string {
	return normalizeOperandValue(attr)
}

// ResolveDataAlias 统一 data 字段别名。
func ResolveDataAlias(attr string) string {
	return normalizeOperandValue(attr)
}

// NormalizeRuleOperand 统一规则操作数。
func NormalizeRuleOperand(raw string) string {
	return normalizeOperandValue(raw)
}

// NormalizeRuleValues 统一规则值列表。
func NormalizeRuleValues(values []string) []string {
	normalized := make([]string, 0, len(values))
	for _, value := range values {
		trimmed := normalizeOperandValue(value)
		if trimmed == "" {
			continue
		}
		normalized = append(normalized, trimmed)
	}
	return normalized
}

// BuildRuleContext 快速构建 ABAC context（测试/工具场景）。
func BuildRuleContext(actor map[string]string, tenantID string, data map[string]string) context.Context {
	ctx := context.Background()
	ctx = ExposeActorAttrsToContext(ctx, actor)
	ctx = ExposeTenantToContext(ctx, tenantID)
	ctx = ExposeABACDataToContext(ctx, data)
	return ctx
}

// EvalAndRules 直接评估 and 规则集合。
func EvalAndRules(ctx context.Context, rules ...privacy.QueryMutationRule) error {
	return AndRule(rules...).EvalQuery(ctx, nil)
}

// EvalOrRules 直接评估 or 规则集合。
func EvalOrRules(ctx context.Context, rules ...privacy.QueryMutationRule) error {
	return OrRule(rules...).EvalQuery(ctx, nil)
}

// EnsureScopePrefix 为操作数补齐作用域前缀。
func EnsureScopePrefix(scope string, attr string) string {
	normalizedScope := normalizeOperandValue(scope)
	normalizedAttr := normalizeOperandValue(attr)
	if normalizedScope == "" {
		return normalizedAttr
	}
	return normalizedScope + "." + normalizedAttr
}

// SplitScopeOperand 拆分 scope.operand。
func SplitScopeOperand(raw string) (string, string) {
	normalized := normalizeOperandValue(raw)
	parts := strings.SplitN(normalized, ".", 2)
	if len(parts) == 2 {
		return parts[0], parts[1]
	}
	return "", normalized
}

// ResolveOperandAsScopeAttr 解析 scope.operand 到 context 值。
func ResolveOperandAsScopeAttr(ctx context.Context, operand string) string {
	scope, attr := SplitScopeOperand(operand)
	if scope == "" {
		return dataAttrFromContext(ctx, attr)
	}
	return ResolveScopeAttr(ctx, scope, attr)
}

// RuleFromOperandEq 根据 scope.operand 构建 eq 规则。
func RuleFromOperandEq(operand string, expected string) privacy.QueryMutationRule {
	scope, attr := SplitScopeOperand(operand)
	if scope == "" {
		return AllowIfDataEq(attr, expected)
	}
	return NewScopeEqRule(scope, attr, expected)
}

// RuleFromOperandIn 根据 scope.operand 构建 in 规则。
func RuleFromOperandIn(operand string, allowValues []string) privacy.QueryMutationRule {
	scope, attr := SplitScopeOperand(operand)
	if scope == "" {
		return AllowIfDataIn(attr, allowValues)
	}
	return NewScopeInRule(scope, attr, allowValues)
}

// RuleFromOperandCmp 根据 scope.operand 构建 cmp 规则。
func RuleFromOperandCmp(operand string, op string, threshold string) privacy.QueryMutationRule {
	scope, attr := SplitScopeOperand(operand)
	if scope == "" {
		return CmpFieldRule(attr, op, threshold)
	}
	return NewScopeCmpRule(scope, attr, op, threshold)
}

// RuleFromRole 构建 role 规则。
func RuleFromRole(role string) privacy.QueryMutationRule {
	return AllowIfRole(role)
}

// RuleFromTenantID 构建 tenant.id 规则。
func RuleFromTenantID(tenantID string) privacy.QueryMutationRule {
	return AllowIfTenantEq("id", tenantID)
}

// RuleFromDataField 构建 data 字段规则。
func RuleFromDataField(field string, expected string) privacy.QueryMutationRule {
	return AllowIfDataEq(field, expected)
}

// RuleFromActorField 构建 actor 字段规则。
func RuleFromActorField(field string, expected string) privacy.QueryMutationRule {
	return AllowIfActorEq(field, expected)
}

// RuleFromTenantField 构建 tenant 字段规则。
func RuleFromTenantField(field string, expected string) privacy.QueryMutationRule {
	return AllowIfTenantEq(field, expected)
}

// RuleSetFromValues 根据 scope+field+values 构建 in 规则。
func RuleSetFromValues(scope string, field string, values []string) privacy.QueryMutationRule {
	switch strings.ToLower(normalizeOperandValue(scope)) {
	case "actor":
		return AllowIfActorIn(field, values)
	case "tenant":
		return AllowIfTenantIn(field, values)
	case "data":
		return AllowIfDataIn(field, values)
	default:
		return InFieldRule(field, values)
	}
}

// RuleEqFromScope 根据 scope+field+value 构建 eq 规则。
func RuleEqFromScope(scope string, field string, value string) privacy.QueryMutationRule {
	switch strings.ToLower(normalizeOperandValue(scope)) {
	case "actor":
		return AllowIfActorEq(field, value)
	case "tenant":
		return AllowIfTenantEq(field, value)
	case "data":
		return AllowIfDataEq(field, value)
	default:
		return EqFieldRule(field, value)
	}
}

// RuleCmpFromScope 根据 scope+field+cmp 构建比较规则。
func RuleCmpFromScope(scope string, field string, op string, threshold string) privacy.QueryMutationRule {
	switch strings.ToLower(normalizeOperandValue(scope)) {
	case "data", "":
		return CmpFieldRule(field, op, threshold)
	default:
		return NewScopeCmpRule(scope, field, op, threshold)
	}
}

// MustRule 在规则为空时返回 fail-closed 规则。
func MustRule(rule privacy.QueryMutationRule, reason string) privacy.QueryMutationRule {
	if rule == nil {
		return NewFailClosedRule(reason)
	}
	return rule
}

// WrapRuleWithReason 为规则补充兜底拒绝原因（Query 与 Mutation 共用）。
func WrapRuleWithReason(rule privacy.QueryMutationRule, reason string) privacy.QueryMutationRule {
	baseRule := MustRule(rule, reason)
	return compositeRule{
		mode: compositeAnd,
		rules: []privacy.QueryMutationRule{
			baseRule,
			privacy.ContextQueryMutationRule(func(_ context.Context) error {
				return privacy.Allow
			}),
		},
	}
}
