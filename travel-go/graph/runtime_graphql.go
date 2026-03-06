package graph

import (
	"context"
	"fmt"
	"sort"
	"strings"
)

// RuntimeError 统一运行时错误结构。
type RuntimeError struct {
	Code    string `json:"code"`
	Reason  string `json:"reason,omitempty"`
	Path    string `json:"path,omitempty"`
	Message string `json:"message"`
}

func (e *RuntimeError) Error() string {
	if e == nil {
		return "runtime error"
	}
	return e.Message
}

func runtimeErr(code, message string) error {
	return &RuntimeError{Code: code, Reason: code, Message: message}
}

func runtimeErrWithPath(code string, reason string, path string, message string) error {
	if strings.TrimSpace(reason) == "" {
		reason = code
	}
	return &RuntimeError{
		Code:    code,
		Reason:  reason,
		Path:    path,
		Message: message,
	}
}

// RuntimeConfig 定义 GraphQL runtime 需要的最小钩子集合。
type RuntimeConfig struct {
	// strict: 未知 map-step 直接阻断；compat: 降级并输出结构化告警。
	Mode string
	Resolve func(meta map[string]interface{}, parent interface{}, args map[string]interface{}, resolution map[string]interface{}) (interface{}, error)
	// 可选：是否启用 postprocess，缺省为 true。
	PostprocessEnabled func() bool
	// 可选：返回 map 结构的 phase -> []step。
	PostprocessPlan func(meta map[string]interface{}, parent interface{}, args map[string]interface{}, resolution map[string]interface{}) map[string]interface{}
	// 可选：报表查询鉴权钩子（与 Elixir authorize_report_query 对齐）。
	AuthorizeReportQuery func(reportMeta map[string]interface{}, args map[string]interface{}, gqlContext map[string]interface{}, runtimeCtx map[string]interface{}) (interface{}, error)
	// 可选：接收 compat 模式下降级告警（code/reason/path/message）。
	OnRuntimeWarning func(code string, reason string, path string, message string)
}

// ResolveWith 统一执行：resolve -> resolve_children -> post -> finalize。
func ResolveWith(cfg RuntimeConfig, meta map[string]interface{}, parent interface{}, args map[string]interface{}, resolution map[string]interface{}) (interface{}, error) {
	if cfg.Resolve == nil {
		return nil, runtimeErr("resolve_missing", "runtime resolve hook 未配置")
	}
	resolved, err := cfg.Resolve(meta, parent, args, resolution)
	if err != nil {
		return nil, err
	}

	ctx := map[string]interface{}{
		"meta":       meta,
		"parent":     parent,
		"args":       args,
		"resolution": resolution,
		"runtime_mode": resolveRuntimeMode(cfg),
		"runtime_warning_hook": cfg.OnRuntimeWarning,
	}

	reportResolved, err := maybeExecuteReport(cfg, resolved, meta, args, ctx)
	if err != nil {
		return nil, err
	}

	plan := map[string]interface{}{}
	if postprocessEnabled(cfg) && cfg.PostprocessPlan != nil {
		if loaded := cfg.PostprocessPlan(meta, parent, args, resolution); loaded != nil {
			plan = loaded
		}
	}

	childResolved, err := runPhase(plan, "resolve_children", reportResolved, ctx)
	if err != nil {
		return nil, err
	}
	postProcessed, err := runPhase(plan, "post", childResolved, ctx)
	if err != nil {
		return nil, err
	}
	finalized, err := runPhase(plan, "finalize", postProcessed, ctx)
	if err != nil {
		return nil, err
	}
	return finalized, nil
}

func postprocessEnabled(cfg RuntimeConfig) bool {
	if cfg.PostprocessEnabled == nil {
		return true
	}
	return cfg.PostprocessEnabled()
}

func resolveRuntimeMode(cfg RuntimeConfig) string {
	mode := normalizeWord(cfg.Mode)
	if mode == "" {
		return "compat"
	}
	if mode == "strict" {
		return "strict"
	}
	return "compat"
}

func runPhase(plan map[string]interface{}, phase string, value interface{}, ctx map[string]interface{}) (interface{}, error) {
	for _, step := range mapSlice(mapGet(plan, phase)) {
		next, err := applyMapStep(step, value, ctx)
		if err != nil {
			return nil, err
		}
		value = next
	}
	return value, nil
}

func applyMapStep(step map[string]interface{}, value interface{}, ctx map[string]interface{}) (interface{}, error) {
	op := normalizeWord(mapGet(step, "op"))
	switch op {
	case "":
		return value, nil
	case "transform":
		return applyTransform(step, value), nil
	case "aggregate":
		return applyAggregate(step, value), nil
	case "expose":
		return applyExpose(step, value), nil
	case "collect":
		return applyCollect(step, value), nil
	case "template_adapter":
		return applyTemplateAdapter(step, value), nil
	default:
		code := "unsupported_postprocess_op"
		reason := "unsupported_postprocess_op"
		path := "postprocess_plan/*/op"
		message := fmt.Sprintf("unsupported op=%s (ctx=%v)", op, ctx)
		if toString(mapGet(ctx, "runtime_mode")) == "strict" {
			return nil, runtimeErrWithPath(code, reason, path, message)
		}
		emitRuntimeWarning(ctx, code, reason, path, message)
		return attachRuntimeWarning(value, code, reason, path, message), nil
	}
}

func emitRuntimeWarning(ctx map[string]interface{}, code string, reason string, path string, message string) {
	hook, ok := mapGet(ctx, "runtime_warning_hook").(func(string, string, string, string))
	if !ok || hook == nil {
		return
	}
	hook(code, reason, path, message)
}

func attachRuntimeWarning(value interface{}, code string, reason string, path string, message string) interface{} {
	record, ok := value.(map[string]interface{})
	if !ok {
		return value
	}
	copied := copyMap(record)
	warning := map[string]interface{}{
		"code": code,
		"reason": reason,
		"path": path,
		"message": message,
	}
	existing := mapSlice(mapGet(copied, "_runtime_warnings"))
	next := make([]interface{}, 0, len(existing)+1)
	for _, item := range existing {
		next = append(next, item)
	}
	next = append(next, warning)
	copied["_runtime_warnings"] = next
	return copied
}

func applyTransform(step map[string]interface{}, value interface{}) interface{} {
	source := toString(mapGet(step, "source"))
	target := toString(mapGet(step, "target"))
	def := mapGet(step, "default")
	return updateEachRecord(value, func(record map[string]interface{}) map[string]interface{} {
		return putField(record, target, withDefault(readPath(record, source), def))
	})
}

func applyExpose(step map[string]interface{}, value interface{}) interface{} {
	source := toString(mapGet(step, "source"))
	target := toString(mapGet(step, "alias"))
	if target == "" {
		target = toString(mapGet(step, "target"))
	}
	def := mapGet(step, "default")
	return updateEachRecord(value, func(record map[string]interface{}) map[string]interface{} {
		return putField(record, target, withDefault(readPath(record, source), def))
	})
}

func applyAggregate(step map[string]interface{}, value interface{}) interface{} {
	source := toString(mapGet(step, "source"))
	target := toString(mapGet(step, "target"))
	fnName := normalizeWord(mapGet(step, "function"))
	if fnName == "" {
		fnName = "count"
	}
	def := mapGet(step, "default")
	return updateEachRecord(value, func(record map[string]interface{}) map[string]interface{} {
		values := collectValues(readPath(record, source))
		return putField(record, target, withDefault(aggregateValues(fnName, values, step), def))
	})
}

func applyCollect(step map[string]interface{}, value interface{}) interface{} {
	source := toString(mapGet(step, "source"))
	collector := normalizeWord(mapGet(step, "collector"))
	if collector == "" {
		collector = "list"
	}
	target := toString(mapGet(step, "target"))
	if target == "" {
		target = toString(mapGet(step, "alias"))
	}
	if target == "" {
		target = toString(mapGet(step, "name"))
	}
	def := mapGet(step, "default")

	return updateEachRecord(value, func(record map[string]interface{}) map[string]interface{} {
		values := collectValues(readPath(record, source))
		collected := collectWith(collector, values, step)
		return putField(record, target, withDefault(collected, def))
	})
}

func applyTemplateAdapter(step map[string]interface{}, value interface{}) interface{} {
	pageKind := normalizeWord(mapGet(step, "page_kind"))
	if pageKind == "" {
		pageKind = "detail"
	}
	pageType := normalizeWord(mapGet(step, "page_type"))
	if pageType == "" {
		pageType = "object_page"
	}

	state := normalizeMap(mapGet(step, "state_defaults"))
	for _, key := range stringSlice(mapGet(step, "status_keys")) {
		if _, ok := state[key]; !ok {
			state[key] = nil
		}
	}

	var adapted map[string]interface{}
	if pageKind == "list" {
		rows := normalizeRows(value)
		adapted = copyMap(state)
		adapted["rows"] = rows
		adapted["rows_empty"] = len(rows) == 0
		adapted["loading"] = false
		adapted["raw"] = value
		if pageType == "analytical_page" || pageType == "overview_page" {
			adapted["chart"] = map[string]interface{}{"series": buildChartSeries(rows)}
			adapted["chart_ready"] = len(rows) > 0
		}
	} else {
		record := firstRecord(value)
		adapted = copyMap(state)
		adapted["record"] = record
		adapted["data"] = record
		adapted["loading"] = false
		adapted["raw"] = value
	}

	putIfPresent(adapted, "_page_id", mapGet(step, "page_id"))
	putIfPresent(adapted, "_page_kind", pageKind)
	putIfPresent(adapted, "_page_type", pageType)
	putIfPresent(adapted, "_transitions", mapGet(step, "transitions"))
	putIfPresent(adapted, "_api_map", normalizeMap(mapGet(step, "api_map")))
	putIfPresent(adapted, "_report_meta", mapGet(step, "report_meta"))
	putIfPresent(adapted, "_report_route", mapGet(step, "report_route"))
	putIfPresent(adapted, "_degrade_signal", mapGet(step, "degrade_signal"))
	return adapted
}

func buildChartSeries(rows []map[string]interface{}) []map[string]interface{} {
	grouped := map[string]int{}
	for _, row := range rows {
		label := toString(mapGet(row, "status"))
		if strings.TrimSpace(label) == "" {
			label = "unknown"
		}
		grouped[label]++
	}
	keys := make([]string, 0, len(grouped))
	for key := range grouped {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	series := make([]map[string]interface{}, 0, len(keys))
	for _, key := range keys {
		series = append(series, map[string]interface{}{"name": key, "value": grouped[key]})
	}
	return series
}

// ExecuteReport 执行最小报表运行时：group/filter/sort/limit + tenant + authorize hook。
func ExecuteReport(cfg RuntimeConfig, value interface{}, reportMeta map[string]interface{}, args map[string]interface{}, runtimeCtx map[string]interface{}) (interface{}, error) {
	normalizedArgs := normalizeReportArgs(args)
	if err := ensureTenant(runtimeCtx); err != nil {
		return nil, err
	}
	if err := authorizeReport(cfg, reportMeta, normalizedArgs, runtimeCtx); err != nil {
		return nil, err
	}

	rows := normalizeRows(value)
	runtime, err := buildReportRuntime(reportMeta, normalizedArgs)
	if err != nil {
		return nil, err
	}
	filtered := applyReportFilters(rows, runtime)
	grouped := groupAndMeasure(filtered, runtime)
	sortedRows := sortReportRows(grouped, runtime.SortSpecs)
	limited, err := limitReportRows(sortedRows, runtime.Limit)
	if err != nil {
		return nil, err
	}
	return limited, nil
}

func maybeExecuteReport(cfg RuntimeConfig, value interface{}, meta map[string]interface{}, args map[string]interface{}, runtimeCtx map[string]interface{}) (interface{}, error) {
	reportMeta := normalizeMap(mapGet(meta, "report_meta"))
	if len(reportMeta) == 0 {
		return value, nil
	}
	return ExecuteReport(cfg, value, reportMeta, args, runtimeCtx)
}

type reportArgs struct {
	GroupBy  []string
	Measures []string
	Filters  []reportFilter
	Sort     []reportSort
	Limit    interface{}
}

type reportFilter struct {
	Name  string
	Op    string
	Value interface{}
}

type reportSort struct {
	Field     string
	Direction string
}

type reportRuntime struct {
	Dimensions       map[string]string
	Measures         map[string]map[string]interface{}
	DeclaredFilters  map[string]struct{}
	GroupBy          []string
	SelectedMeasures []string
	FilterSpecs      []reportFilter
	SortSpecs        []reportSort
	Limit            *int
}

func normalizeReportArgs(args map[string]interface{}) reportArgs {
	if args == nil {
		return reportArgs{}
	}
	return reportArgs{
		GroupBy:  stringSlice(mapGet(args, "group_by")),
		Measures: stringSlice(mapGet(args, "measures")),
		Filters:  normalizeFilters(mapGet(args, "filters")),
		Sort:     normalizeSorts(mapGet(args, "sort")),
		Limit:    mapGet(args, "limit"),
	}
}

func buildReportRuntime(reportMeta map[string]interface{}, args reportArgs) (reportRuntime, error) {
	dimensions := buildDimensionIndex(mapGet(reportMeta, "dimensions"))
	measures := buildMeasureIndex(mapGet(reportMeta, "measures"))
	filters := buildFilterIndex(mapGet(reportMeta, "filters"))

	groupBy := withDefaults(args.GroupBy, stringSlice(mapGet(reportMeta, "default_dimensions")))
	measuresSelected := withDefaults(args.Measures, stringSlice(mapGet(reportMeta, "default_measures")))
	filterSpecs := withFilterDefaults(args.Filters, normalizeFilters(mapGet(reportMeta, "default_filters")))
	sortSpecs := withSortDefaults(args.Sort, normalizeSorts(mapGet(reportMeta, "default_sort")))

	if err := validateGroupBy(groupBy, dimensions); err != nil {
		return reportRuntime{}, err
	}
	validatedMeasures, err := validateMeasures(measuresSelected, measures)
	if err != nil {
		return reportRuntime{}, err
	}
	if err := validateFilters(filterSpecs, filters, dimensions); err != nil {
		return reportRuntime{}, err
	}
	limit, err := validateLimit(args.Limit)
	if err != nil {
		return reportRuntime{}, err
	}
	validatedSort, err := validateSort(sortSpecs, groupBy, validatedMeasures)
	if err != nil {
		return reportRuntime{}, err
	}

	return reportRuntime{
		Dimensions:       dimensions,
		Measures:         measures,
		DeclaredFilters:  filters,
		GroupBy:          groupBy,
		SelectedMeasures: validatedMeasures,
		FilterSpecs:      filterSpecs,
		SortSpecs:        validatedSort,
		Limit:            limit,
	}, nil
}

func ensureTenant(runtimeCtx map[string]interface{}) error {
	tenant := strings.TrimSpace(toString(mapGet(runtimeCtx, "tenant")))
	if tenant == "" {
		tenant = strings.TrimSpace(toString(mapGet(runtimeCtx, "tenant_id")))
	}
	gqlCtx := normalizeMap(mapGet(runtimeCtx, "context"))
	if tenant == "" {
		tenant = strings.TrimSpace(toString(mapGet(gqlCtx, "tenant")))
	}
	if tenant == "" {
		tenant = strings.TrimSpace(toString(mapGet(gqlCtx, "tenant_id")))
	}
	if tenant == "" {
		return runtimeErrWithPath("tenant_required", "tenant_required", "runtime_context/tenant", "报表查询缺少 tenant 上下文")
	}
	return nil
}

func authorizeReport(cfg RuntimeConfig, reportMeta map[string]interface{}, args reportArgs, runtimeCtx map[string]interface{}) error {
	if cfg.AuthorizeReportQuery == nil {
		return nil
	}
	normalizedArgs := map[string]interface{}{
		"group_by": args.GroupBy,
		"measures": args.Measures,
		"filters":  filtersAsMap(args.Filters),
		"sort":     sortsAsMap(args.Sort),
		"limit":    args.Limit,
	}
	gqlCtx := normalizeMap(mapGet(runtimeCtx, "context"))
	decision, err := cfg.AuthorizeReportQuery(reportMeta, normalizedArgs, gqlCtx, runtimeCtx)
	if err != nil {
		return runtimeErrWithPath("forbidden", "report_auth_denied", "report_meta/authorize_report_query", fmt.Sprintf("报表权限校验失败: %v", err))
	}
	switch normalizeAuthDecision(decision) {
	case "allow", "":
		return nil
	case "deny":
		return runtimeErrWithPath("forbidden", "report_auth_denied", "report_meta/authorize_report_query", "报表权限校验拒绝访问")
	default:
		return runtimeErrWithPath("report_auth_invalid", "report_auth_invalid", "report_meta/authorize_report_query", fmt.Sprintf("报表权限钩子返回非法值: %v", decision))
	}
}

func normalizeAuthDecision(value interface{}) string {
	switch typed := value.(type) {
	case nil:
		return ""
	case bool:
		if typed {
			return "allow"
		}
		return "deny"
	case string:
		normalized := normalizeWord(typed)
		if normalized == "allow" || normalized == "deny" {
			return normalized
		}
		return normalized
	default:
		return fmt.Sprintf("%v", value)
	}
}

func filtersAsMap(filters []reportFilter) []map[string]interface{} {
	items := make([]map[string]interface{}, 0, len(filters))
	for _, item := range filters {
		items = append(items, map[string]interface{}{
			"name":  item.Name,
			"op":    item.Op,
			"value": item.Value,
		})
	}
	return items
}

func sortsAsMap(sorts []reportSort) []map[string]interface{} {
	items := make([]map[string]interface{}, 0, len(sorts))
	for _, item := range sorts {
		items = append(items, map[string]interface{}{
			"field":     item.Field,
			"direction": item.Direction,
		})
	}
	return items
}

func applyReportFilters(rows []map[string]interface{}, runtime reportRuntime) []map[string]interface{} {
	if len(runtime.FilterSpecs) == 0 {
		return rows
	}
	filtered := make([]map[string]interface{}, 0, len(rows))
	for _, row := range rows {
		matched := true
		for _, filter := range runtime.FilterSpecs {
			if !matchFilter(row, filter, runtime) {
				matched = false
				break
			}
		}
		if matched {
			filtered = append(filtered, row)
		}
	}
	return filtered
}

func groupAndMeasure(rows []map[string]interface{}, runtime reportRuntime) []map[string]interface{} {
	if len(runtime.GroupBy) == 0 {
		if len(rows) == 0 {
			return []map[string]interface{}{}
		}
		return []map[string]interface{}{measureRow(rows, map[string]interface{}{}, runtime)}
	}

	grouped := map[string][]map[string]interface{}{}
	groupValues := map[string][]interface{}{}
	for _, row := range rows {
		values := make([]interface{}, 0, len(runtime.GroupBy))
		keyParts := make([]string, 0, len(runtime.GroupBy))
		for _, dimensionName := range runtime.GroupBy {
			dimensionField := runtime.Dimensions[dimensionName]
			if strings.TrimSpace(dimensionField) == "" {
				dimensionField = dimensionName
			}
			val := readPath(row, dimensionField)
			values = append(values, val)
			keyParts = append(keyParts, fmt.Sprintf("%v", val))
		}
		key := strings.Join(keyParts, "|")
		grouped[key] = append(grouped[key], row)
		groupValues[key] = values
	}

	keys := make([]string, 0, len(grouped))
	for key := range grouped {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	result := make([]map[string]interface{}, 0, len(keys))
	for _, key := range keys {
		base := map[string]interface{}{}
		values := groupValues[key]
		for i, name := range runtime.GroupBy {
			if i < len(values) {
				base[name] = values[i]
			}
		}
		result = append(result, measureRow(grouped[key], base, runtime))
	}
	return result
}

func measureRow(rows []map[string]interface{}, base map[string]interface{}, runtime reportRuntime) map[string]interface{} {
	acc := copyMap(base)
	for _, measureName := range runtime.SelectedMeasures {
		acc[measureName] = computeMeasure(rows, runtime.Measures[measureName])
	}
	return acc
}

func computeMeasure(rows []map[string]interface{}, measure map[string]interface{}) interface{} {
	op := normalizeWord(mapGet(measure, "op"))
	field := toString(mapGet(measure, "field"))

	switch op {
	case "count":
		return len(rows)
	case "sum":
		sum := 0.0
		for _, row := range rows {
			sum += toFloat(readPath(row, field))
		}
		return sum
	case "min":
		values := numericValues(rows, field)
		if len(values) == 0 {
			return nil
		}
		min := values[0]
		for _, value := range values[1:] {
			if value < min {
				min = value
			}
		}
		return min
	case "max":
		values := numericValues(rows, field)
		if len(values) == 0 {
			return nil
		}
		max := values[0]
		for _, value := range values[1:] {
			if value > max {
				max = value
			}
		}
		return max
	case "avg":
		values := numericValues(rows, field)
		if len(values) == 0 {
			return nil
		}
		sum := 0.0
		for _, value := range values {
			sum += value
		}
		return sum / float64(len(values))
	default:
		return nil
	}
}

func numericValues(rows []map[string]interface{}, field string) []float64 {
	values := make([]float64, 0, len(rows))
	for _, row := range rows {
		values = append(values, toFloat(readPath(row, field)))
	}
	return values
}

func sortReportRows(rows []map[string]interface{}, sortSpecs []reportSort) []map[string]interface{} {
	if len(sortSpecs) == 0 {
		return rows
	}
	sortedRows := append([]map[string]interface{}(nil), rows...)
	sort.SliceStable(sortedRows, func(i, j int) bool {
		return compareBySortSpecs(sortedRows[i], sortedRows[j], sortSpecs)
	})
	return sortedRows
}

func limitReportRows(rows []map[string]interface{}, limit *int) ([]map[string]interface{}, error) {
	if limit == nil {
		return rows, nil
	}
	if *limit <= 0 {
		return nil, runtimeErr("invalid_report_limit", "limit 必须为正整数")
	}
	if *limit >= len(rows) {
		return rows, nil
	}
	return rows[:*limit], nil
}

func compareBySortSpecs(left map[string]interface{}, right map[string]interface{}, sortSpecs []reportSort) bool {
	for _, spec := range sortSpecs {
		cmp := compareValues(mapGet(left, spec.Field), mapGet(right, spec.Field))
		if cmp == 0 {
			continue
		}
		if spec.Direction == "desc" {
			return cmp > 0
		}
		return cmp < 0
	}
	return true
}

func compareValues(left interface{}, right interface{}) int {
	lv := fmt.Sprintf("%v", left)
	rv := fmt.Sprintf("%v", right)
	if toFloat(left) != 0 || toFloat(right) != 0 {
		lf := toFloat(left)
		rf := toFloat(right)
		if lf < rf {
			return -1
		}
		if lf > rf {
			return 1
		}
		return 0
	}
	if lv < rv {
		return -1
	}
	if lv > rv {
		return 1
	}
	return 0
}

func matchFilter(row map[string]interface{}, filter reportFilter, runtime reportRuntime) bool {
	field := runtime.Dimensions[filter.Name]
	if field == "" {
		field = filter.Name
	}
	value := readPath(row, field)
	switch filter.Op {
	case "eq":
		return fmt.Sprintf("%v", value) == fmt.Sprintf("%v", filter.Value)
	case "neq":
		return fmt.Sprintf("%v", value) != fmt.Sprintf("%v", filter.Value)
	case "in":
		for _, candidate := range collectValues(filter.Value) {
			if fmt.Sprintf("%v", value) == fmt.Sprintf("%v", candidate) {
				return true
			}
		}
		return false
	case "gt":
		return toFloat(value) > toFloat(filter.Value)
	case "gte":
		return toFloat(value) >= toFloat(filter.Value)
	case "lt":
		return toFloat(value) < toFloat(filter.Value)
	case "lte":
		return toFloat(value) <= toFloat(filter.Value)
	default:
		return false
	}
}

func validateGroupBy(groupBy []string, dimensions map[string]string) error {
	invalid := make([]string, 0)
	for _, name := range groupBy {
		if _, ok := dimensions[name]; !ok {
			invalid = append(invalid, name)
		}
	}
	if len(invalid) > 0 {
		return runtimeErrWithPath("invalid_report_group_by", "invalid_report_group_by", "report_args/group_by", fmt.Sprintf("非法 group_by 维度: %s", strings.Join(invalid, ",")))
	}
	return nil
}

func validateMeasures(measures []string, index map[string]map[string]interface{}) ([]string, error) {
	if len(measures) == 0 {
		keys := make([]string, 0, len(index))
		for key := range index {
			keys = append(keys, key)
		}
		sort.Strings(keys)
		return keys, nil
	}
	invalid := make([]string, 0)
	for _, name := range measures {
		if _, ok := index[name]; !ok {
			invalid = append(invalid, name)
		}
	}
	if len(invalid) > 0 {
		return nil, runtimeErrWithPath("invalid_report_measures", "invalid_report_measures", "report_args/measures", fmt.Sprintf("非法 measures: %s", strings.Join(invalid, ",")))
	}
	return measures, nil
}

func validateFilters(filters []reportFilter, declared map[string]struct{}, dimensions map[string]string) error {
	invalid := make([]string, 0)
	for _, filter := range filters {
		if _, ok := declared[filter.Name]; ok {
			continue
		}
		if _, ok := dimensions[filter.Name]; ok {
			continue
		}
		invalid = append(invalid, filter.Name)
	}
	if len(invalid) > 0 {
		return runtimeErrWithPath("invalid_report_filters", "invalid_report_filters", "report_args/filters", fmt.Sprintf("非法 filters: %s", strings.Join(invalid, ",")))
	}
	return nil
}

func validateLimit(raw interface{}) (*int, error) {
	if raw == nil {
		return nil, nil
	}
	limit := toInt(raw)
	if limit <= 0 || limit > 1000 {
		return nil, runtimeErrWithPath("invalid_report_limit", "invalid_report_limit", "report_args/limit", "limit 必须是 1..1000")
	}
	return &limit, nil
}

func validateSort(sortSpecs []reportSort, groupBy []string, measures []string) ([]reportSort, error) {
	allowed := map[string]struct{}{}
	for _, key := range groupBy {
		allowed[key] = struct{}{}
	}
	for _, key := range measures {
		allowed[key] = struct{}{}
	}
	result := make([]reportSort, 0, len(sortSpecs))
	for _, spec := range sortSpecs {
		field := strings.TrimSpace(spec.Field)
		if field == "" {
			return nil, runtimeErrWithPath("invalid_report_sort", "invalid_report_sort", "report_args/sort/field", "sort.field 不能为空")
		}
		if _, ok := allowed[field]; !ok {
			return nil, runtimeErrWithPath("invalid_report_sort", "invalid_report_sort", "report_args/sort/field", fmt.Sprintf("sort.field 不可用: %s", field))
		}
		direction := normalizeWord(spec.Direction)
		if direction == "" {
			direction = "asc"
		}
		if direction != "asc" && direction != "desc" {
			return nil, runtimeErrWithPath("invalid_report_sort", "invalid_report_sort", "report_args/sort/direction", "sort.direction 仅支持 asc/desc")
		}
		result = append(result, reportSort{Field: field, Direction: direction})
	}
	return result, nil
}

func normalizeFilters(raw interface{}) []reportFilter {
	items := mapSlice(raw)
	result := make([]reportFilter, 0, len(items))
	for _, item := range items {
		name := strings.TrimSpace(toString(mapGet(item, "name")))
		if name == "" {
			name = strings.TrimSpace(toString(mapGet(item, "field")))
		}
		if name == "" {
			continue
		}
		op := normalizeWord(mapGet(item, "op"))
		if op == "" {
			op = "eq"
		}
		result = append(result, reportFilter{
			Name:  name,
			Op:    op,
			Value: mapGet(item, "value"),
		})
	}
	return result
}

func normalizeSorts(raw interface{}) []reportSort {
	items := mapSlice(raw)
	result := make([]reportSort, 0, len(items))
	for _, item := range items {
		field := strings.TrimSpace(toString(mapGet(item, "field")))
		if field == "" {
			continue
		}
		result = append(result, reportSort{
			Field:     field,
			Direction: strings.TrimSpace(toString(mapGet(item, "direction"))),
		})
	}
	return result
}

func buildDimensionIndex(raw interface{}) map[string]string {
	result := map[string]string{}
	for _, item := range mapSlice(raw) {
		name := strings.TrimSpace(toString(mapGet(item, "name")))
		field := strings.TrimSpace(toString(mapGet(item, "field")))
		if name == "" {
			continue
		}
		if field == "" {
			field = name
		}
		result[name] = field
	}
	return result
}

func buildMeasureIndex(raw interface{}) map[string]map[string]interface{} {
	result := map[string]map[string]interface{}{}
	for _, item := range mapSlice(raw) {
		name := strings.TrimSpace(toString(mapGet(item, "name")))
		op := normalizeWord(mapGet(item, "op"))
		field := strings.TrimSpace(toString(mapGet(item, "field")))
		if name == "" || op == "" {
			continue
		}
		if op != "count" && op != "sum" && op != "min" && op != "max" && op != "avg" {
			continue
		}
		spec := map[string]interface{}{"op": op}
		if field != "" {
			spec["field"] = field
		}
		result[name] = spec
	}
	return result
}

func buildFilterIndex(raw interface{}) map[string]struct{} {
	result := map[string]struct{}{}
	for _, item := range mapSlice(raw) {
		name := strings.TrimSpace(toString(mapGet(item, "name")))
		if name == "" {
			continue
		}
		result[name] = struct{}{}
	}
	return result
}

// PostprocessPlanFor 从 graphql manifest 读取字段 postprocess_plan。
func PostprocessPlanFor(manifest map[string]interface{}, metaOrField interface{}) map[string]interface{} {
	fieldName := normalizeMetaField(metaOrField)
	if fieldName == "" {
		return nil
	}
	field := findGraphqlField(manifest, fieldName)
	if field == nil {
		return nil
	}
	plan := normalizeMap(mapGet(field, "postprocess_plan"))
	if len(plan) == 0 {
		return nil
	}
	return plan
}

// ReportMetaFor 从 graphql manifest 读取字段 report_meta。
func ReportMetaFor(manifest map[string]interface{}, metaOrField interface{}) map[string]interface{} {
	fieldName := normalizeMetaField(metaOrField)
	if fieldName == "" {
		return nil
	}
	field := findGraphqlField(manifest, fieldName)
	if field == nil {
		return nil
	}
	meta := normalizeMap(mapGet(field, "report_meta"))
	if len(meta) == 0 {
		return nil
	}
	return meta
}

// FrontendPostprocessPlanFor 基于 frontend manifest 构造最小 template_adapter finalize 计划。
func FrontendPostprocessPlanFor(graphqlManifest map[string]interface{}, frontendManifest map[string]interface{}, metaOrField interface{}) map[string]interface{} {
	fieldName := normalizeMetaField(metaOrField)
	if fieldName == "" {
		return nil
	}
	graphqlField := findGraphqlField(graphqlManifest, fieldName)
	if graphqlField == nil {
		return nil
	}
	pages := mapSlice(mapGet(frontendManifest, "pages"))
	page := findFrontendPage(pages, graphqlField)
	if page == nil {
		return nil
	}

	stateSchema := normalizeMap(mapGet(page, "state_schema"))
	statusKeys := stringSlice(mapGet(stateSchema, "status_keys"))
	if len(statusKeys) == 0 {
		statusKeys = stringSlice(mapGet(page, "status_keys"))
	}
	stateDefaults := normalizeMap(mapGet(stateSchema, "defaults"))
	reportMode := reportIntent(graphqlField) || asBool(mapGet(page, "report_mode")) || len(normalizeMap(mapGet(page, "report_meta"))) > 0
	if reportMode {
		statusKeys = ensureReportStatusKeys(statusKeys)
	}

	step := map[string]interface{}{
		"name":           "frontend_template_adapter",
		"op":             "template_adapter",
		"page_id":        mapGet(page, "page_id"),
		"page_kind":      mapGet(page, "page_kind"),
		"page_type":      mapGet(page, "page_type"),
		"status_keys":    statusKeys,
		"state_defaults": stateDefaults,
		"transitions":    withDefault(mapGet(page, "transitions"), []interface{}{}),
		"api_map":        withDefault(mapGet(page, "api_map"), map[string]interface{}{}),
	}
	if reportMode {
		reportMeta := normalizeMap(mapGet(graphqlField, "report_meta"))
		if len(reportMeta) == 0 {
			reportMeta = normalizeMap(mapGet(page, "report_meta"))
		}
		if len(reportMeta) > 0 {
			step["report_meta"] = reportMeta
		} else {
			step["degrade_signal"] = map[string]interface{}{
				"code":   "frontend_template_adapter_report_meta_missing",
				"reason": "report_meta_missing",
				"path":   fmt.Sprintf("frontend_manifest/pages/%s/report_meta", toString(mapGet(page, "page_id"))),
			}
		}
		if route := resolveReportRoute(mapSlice(mapGet(frontendManifest, "route_map")), toString(mapGet(page, "page_id"))); len(route) > 0 {
			step["report_route"] = route
		}
	}

	return map[string]interface{}{
		"finalize": []map[string]interface{}{step},
	}
}

func resolveReportRoute(routeMap []map[string]interface{}, pageID string) map[string]interface{} {
	if strings.TrimSpace(pageID) == "" {
		return map[string]interface{}{}
	}
	for _, route := range routeMap {
		if toString(mapGet(route, "page_id")) == pageID {
			return map[string]interface{}{
				"page_id": pageID,
				"path":    mapGet(route, "path"),
			}
		}
	}
	return map[string]interface{}{}
}

func findFrontendPage(pages []map[string]interface{}, graphqlField map[string]interface{}) map[string]interface{} {
	entity := toString(mapGet(graphqlField, "entity"))
	mode := toString(mapGet(graphqlField, "mode"))
	action := toString(mapGet(graphqlField, "action"))
	isReport := reportIntent(graphqlField)
	preferredKind := "detail"
	if strings.EqualFold(mode, "list") {
		preferredKind = "list"
	}

	candidates := make([]map[string]interface{}, 0)
	for _, page := range pages {
		if toString(mapGet(page, "entity")) != entity {
			continue
		}
		if isReport {
			if asBool(mapGet(page, "report_mode")) || len(normalizeMap(mapGet(page, "report_meta"))) > 0 || strings.EqualFold(toString(mapGet(page, "page_kind")), "list") {
				candidates = append(candidates, page)
			}
		} else if apiSupports(page, mode, action) {
			candidates = append(candidates, page)
		}
	}

	sort.SliceStable(candidates, func(i, j int) bool {
		score := func(page map[string]interface{}) int {
			if isReport && (asBool(mapGet(page, "report_mode")) || len(normalizeMap(mapGet(page, "report_meta"))) > 0) {
				return 0
			}
			if strings.EqualFold(toString(mapGet(page, "page_kind")), preferredKind) {
				return 1
			}
			return 2
		}
		return score(candidates[i]) < score(candidates[j])
	})

	if len(candidates) == 0 {
		return nil
	}
	return candidates[0]
}

func apiSupports(page map[string]interface{}, mode string, action string) bool {
	apiMap := normalizeMap(mapGet(page, "api_map"))
	if len(apiMap) == 0 {
		return false
	}
	if _, ok := apiMap[mode]; ok && strings.TrimSpace(mode) != "" {
		return true
	}
	if _, ok := apiMap[action]; ok && strings.TrimSpace(action) != "" {
		return true
	}
	return false
}

func reportIntent(field map[string]interface{}) bool {
	if len(normalizeMap(mapGet(field, "report_meta"))) > 0 {
		return true
	}
	fieldName := strings.ToLower(toString(mapGet(field, "field")))
	action := strings.ToLower(toString(mapGet(field, "action")))
	return strings.Contains(fieldName, "report") || strings.Contains(action, "report")
}

func ensureReportStatusKeys(statusKeys []string) []string {
	required := []string{"rows", "chart", "chart_ready", "report_state"}
	seen := map[string]struct{}{}
	for _, key := range statusKeys {
		k := strings.TrimSpace(key)
		if k == "" {
			continue
		}
		seen[k] = struct{}{}
	}
	for _, key := range required {
		if _, ok := seen[key]; !ok {
			statusKeys = append(statusKeys, key)
		}
	}
	return statusKeys
}

func normalizeMetaField(metaOrField interface{}) string {
	switch value := metaOrField.(type) {
	case string:
		return strings.TrimSpace(value)
	case map[string]interface{}:
		field := strings.TrimSpace(toString(mapGet(value, "field")))
		if field != "" {
			return field
		}
		return strings.TrimSpace(toString(mapGet(value, "name")))
	default:
		return ""
	}
}

func findGraphqlField(manifest map[string]interface{}, fieldName string) map[string]interface{} {
	for _, item := range mapSlice(mapGet(manifest, "fields")) {
		if toString(mapGet(item, "field")) == fieldName {
			return item
		}
	}
	return nil
}

func updateEachRecord(value interface{}, updater func(map[string]interface{}) map[string]interface{}) interface{} {
	switch typed := value.(type) {
	case []map[string]interface{}:
		rows := make([]map[string]interface{}, 0, len(typed))
		for _, row := range typed {
			rows = append(rows, updater(copyMap(row)))
		}
		return rows
	case []interface{}:
		rows := make([]map[string]interface{}, 0, len(typed))
		for _, item := range typed {
			if row, ok := item.(map[string]interface{}); ok {
				rows = append(rows, updater(copyMap(row)))
			}
		}
		return rows
	case map[string]interface{}:
		copied := copyMap(typed)
		for _, key := range []string{"rows", "data", "items"} {
			if rows := normalizeRows(mapGet(copied, key)); len(rows) > 0 {
				next := make([]map[string]interface{}, 0, len(rows))
				for _, row := range rows {
					next = append(next, updater(copyMap(row)))
				}
				copied[key] = next
				return copied
			}
		}
		return updater(copied)
	default:
		return value
	}
}

func normalizeRows(value interface{}) []map[string]interface{} {
	switch typed := value.(type) {
	case []map[string]interface{}:
		return typed
	case []interface{}:
		rows := make([]map[string]interface{}, 0, len(typed))
		for _, item := range typed {
			if row, ok := item.(map[string]interface{}); ok {
				rows = append(rows, row)
			}
		}
		return rows
	case map[string]interface{}:
		for _, key := range []string{"rows", "data", "items"} {
			if nested := normalizeRows(mapGet(typed, key)); len(nested) > 0 {
				return nested
			}
		}
		if record := normalizeMap(mapGet(typed, "record")); len(record) > 0 {
			return []map[string]interface{}{record}
		}
		return []map[string]interface{}{}
	default:
		return []map[string]interface{}{}
	}
}

func firstRecord(value interface{}) map[string]interface{} {
	rows := normalizeRows(value)
	if len(rows) > 0 {
		return rows[0]
	}
	if item := normalizeMap(value); len(item) > 0 {
		return item
	}
	return map[string]interface{}{}
}

func readPath(value interface{}, path string) interface{} {
	path = strings.TrimSpace(path)
	if path == "" {
		return value
	}
	parts := strings.Split(path, ".")
	current := value
	for _, part := range parts {
		switch typed := current.(type) {
		case map[string]interface{}:
			current = mapGet(typed, part)
		case []interface{}:
			next := make([]interface{}, 0, len(typed))
			for _, item := range typed {
				next = append(next, readPath(item, strings.Join(parts[1:], ".")))
			}
			return next
		default:
			return nil
		}
	}
	return current
}

func collectValues(value interface{}) []interface{} {
	switch typed := value.(type) {
	case nil:
		return []interface{}{}
	case []interface{}:
		values := make([]interface{}, 0, len(typed))
		for _, item := range typed {
			values = append(values, collectValues(item)...)
		}
		return values
	case []map[string]interface{}:
		values := make([]interface{}, 0, len(typed))
		for _, item := range typed {
			values = append(values, item)
		}
		return values
	default:
		return []interface{}{typed}
	}
}

func aggregateValues(function string, values []interface{}, step map[string]interface{}) interface{} {
	switch function {
	case "count":
		return len(values)
	case "sum":
		sum := 0.0
		for _, item := range values {
			sum += toFloat(item)
		}
		return sum
	case "min":
		if len(values) == 0 {
			return nil
		}
		min := toFloat(values[0])
		for _, item := range values[1:] {
			value := toFloat(item)
			if value < min {
				min = value
			}
		}
		return min
	case "max":
		if len(values) == 0 {
			return nil
		}
		max := toFloat(values[0])
		for _, item := range values[1:] {
			value := toFloat(item)
			if value > max {
				max = value
			}
		}
		return max
	case "avg":
		if len(values) == 0 {
			return nil
		}
		sum := 0.0
		for _, item := range values {
			sum += toFloat(item)
		}
		return sum / float64(len(values))
	case "group":
		groupBy := strings.TrimSpace(toString(mapGet(step, "group_by")))
		grouped := map[string]int{}
		for _, item := range values {
			if groupBy != "" {
				if row, ok := item.(map[string]interface{}); ok {
					grouped[fmt.Sprintf("%v", readPath(row, groupBy))]++
					continue
				}
			}
			grouped[fmt.Sprintf("%v", item)]++
		}
		return grouped
	default:
		return nil
	}
}

func collectWith(collector string, values []interface{}, step map[string]interface{}) interface{} {
	switch collector {
	case "list":
		return values
	case "first":
		if len(values) == 0 {
			return nil
		}
		return values[0]
	case "last":
		if len(values) == 0 {
			return nil
		}
		return values[len(values)-1]
	case "uniq":
		seen := map[string]struct{}{}
		result := make([]interface{}, 0, len(values))
		for _, item := range values {
			key := fmt.Sprintf("%v", item)
			if _, ok := seen[key]; ok {
				continue
			}
			seen[key] = struct{}{}
			result = append(result, item)
		}
		return result
	case "join":
		sep := strings.TrimSpace(toString(mapGet(step, "separator")))
		if sep == "" {
			sep = ","
		}
		parts := make([]string, 0, len(values))
		for _, item := range values {
			parts = append(parts, fmt.Sprintf("%v", item))
		}
		return strings.Join(parts, sep)
	case "count":
		return len(values)
	default:
		return values
	}
}

func putField(record map[string]interface{}, target string, value interface{}) map[string]interface{} {
	if strings.TrimSpace(target) == "" {
		return record
	}
	record[target] = value
	return record
}

func withDefault(value interface{}, def interface{}) interface{} {
	if value == nil {
		return def
	}
	switch typed := value.(type) {
	case string:
		if strings.TrimSpace(typed) == "" {
			return def
		}
	}
	return value
}

func mapGet(m map[string]interface{}, key string) interface{} {
	if m == nil {
		return nil
	}
	if value, ok := m[key]; ok {
		return value
	}
	for k, value := range m {
		if strings.EqualFold(strings.TrimSpace(k), strings.TrimSpace(key)) {
			return value
		}
	}
	return nil
}

func mapSlice(raw interface{}) []map[string]interface{} {
	switch typed := raw.(type) {
	case []map[string]interface{}:
		return typed
	case []interface{}:
		items := make([]map[string]interface{}, 0, len(typed))
		for _, item := range typed {
			if mapped, ok := item.(map[string]interface{}); ok {
				items = append(items, mapped)
			}
		}
		return items
	default:
		return []map[string]interface{}{}
	}
}

func stringSlice(raw interface{}) []string {
	switch typed := raw.(type) {
	case []string:
		result := make([]string, 0, len(typed))
		for _, item := range typed {
			trimmed := strings.TrimSpace(item)
			if trimmed != "" {
				result = append(result, trimmed)
			}
		}
		return result
	case []interface{}:
		result := make([]string, 0, len(typed))
		for _, item := range typed {
			trimmed := strings.TrimSpace(fmt.Sprintf("%v", item))
			if trimmed != "" {
				result = append(result, trimmed)
			}
		}
		return result
	default:
		return []string{}
	}
}

func normalizeMap(raw interface{}) map[string]interface{} {
	if mapped, ok := raw.(map[string]interface{}); ok {
		return mapped
	}
	return map[string]interface{}{}
}

func copyMap(input map[string]interface{}) map[string]interface{} {
	if input == nil {
		return map[string]interface{}{}
	}
	output := make(map[string]interface{}, len(input))
	for key, value := range input {
		output[key] = value
	}
	return output
}

func toString(value interface{}) string {
	if value == nil {
		return ""
	}
	return fmt.Sprintf("%v", value)
}

func toFloat(value interface{}) float64 {
	switch typed := value.(type) {
	case float64:
		return typed
	case float32:
		return float64(typed)
	case int:
		return float64(typed)
	case int32:
		return float64(typed)
	case int64:
		return float64(typed)
	case uint:
		return float64(typed)
	case uint32:
		return float64(typed)
	case uint64:
		return float64(typed)
	case string:
		var parsed float64
		_, err := fmt.Sscanf(strings.TrimSpace(typed), "%f", &parsed)
		if err == nil {
			return parsed
		}
		return 0
	default:
		return 0
	}
}

func toInt(value interface{}) int {
	switch typed := value.(type) {
	case int:
		return typed
	case int32:
		return int(typed)
	case int64:
		return int(typed)
	case float64:
		return int(typed)
	case float32:
		return int(typed)
	case string:
		var parsed int
		_, err := fmt.Sscanf(strings.TrimSpace(typed), "%d", &parsed)
		if err == nil {
			return parsed
		}
		return 0
	default:
		return 0
	}
}

func normalizeWord(value interface{}) string {
	return strings.ToLower(strings.TrimSpace(toString(value)))
}

func asBool(value interface{}) bool {
	switch typed := value.(type) {
	case bool:
		return typed
	case string:
		switch strings.ToLower(strings.TrimSpace(typed)) {
		case "1", "true", "yes", "on":
			return true
		default:
			return false
		}
	default:
		return false
	}
}

func withDefaults(values []string, defaults []string) []string {
	if len(values) == 0 {
		return defaults
	}
	return values
}

func withFilterDefaults(values []reportFilter, defaults []reportFilter) []reportFilter {
	if len(values) == 0 {
		return defaults
	}
	return values
}

func withSortDefaults(values []reportSort, defaults []reportSort) []reportSort {
	if len(values) == 0 {
		return defaults
	}
	return values
}

func putIfPresent(target map[string]interface{}, key string, value interface{}) {
	if target == nil || strings.TrimSpace(key) == "" {
		return
	}
	if value == nil {
		return
	}
	target[key] = value
}

var _ = context.Background
