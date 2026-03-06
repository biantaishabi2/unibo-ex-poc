package graph

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"
	"sync/atomic"
	"time"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/vikstrous/dataloadgen"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// loadersContextKey 用于隔离请求级 DataLoader 上下文。
type loadersContextKey struct{}

// loaderStatsContextKey 用于在请求上下文传播 DataLoader 批次统计。
type loaderStatsContextKey struct{}

// LoaderStats 记录请求级批加载统计，便于黑盒验证是否命中批路径。
type LoaderStats struct {
	nodeBatchCalls int64
	nodeBatchKeys  int64
}

func (s *LoaderStats) recordNodeBatch(size int) {
	if s == nil {
		return
	}
	atomic.AddInt64(&s.nodeBatchCalls, 1)
	atomic.AddInt64(&s.nodeBatchKeys, int64(size))
}

func (s *LoaderStats) Snapshot() map[string]interface{} {
	if s == nil {
		return map[string]interface{}{
			"node_batch_calls": int64(0),
			"node_batch_keys":  int64(0),
		}
	}
	return map[string]interface{}{
		"node_batch_calls": atomic.LoadInt64(&s.nodeBatchCalls),
		"node_batch_keys":  atomic.LoadInt64(&s.nodeBatchKeys),
	}
}

// Loaders 汇总当前请求需要的批加载器。
type Loaders struct {
	NodeByID *dataloadgen.Loader[string, ent.Noder]
}

// NewLoaders 创建请求级 DataLoader，默认 2ms 批窗口。
func NewLoaders(client *ent.Client, stats *LoaderStats) *Loaders {
	return &Loaders{
		NodeByID: dataloadgen.NewLoader(func(ctx context.Context, keys []string) ([]ent.Noder, []error) {
			stats.recordNodeBatch(len(keys))
			return batchLoadNodes(ctx, client, keys)
		}, dataloadgen.WithWait(2*time.Millisecond)),
	}
}

// WithLoaders 把请求级 loader 写入上下文。
func WithLoaders(ctx context.Context, loaders *Loaders) context.Context {
	return context.WithValue(ctx, loadersContextKey{}, loaders)
}

// GetLoaders 从上下文读取 loader，不存在时兜底创建。
func GetLoaders(ctx context.Context, client *ent.Client) *Loaders {
	if loaders, ok := ctx.Value(loadersContextKey{}).(*Loaders); ok && loaders != nil {
		return loaders
	}
	return NewLoaders(client, nil)
}

// WithLoaderStats 把请求级统计写入上下文。
func WithLoaderStats(ctx context.Context, stats *LoaderStats) context.Context {
	return context.WithValue(ctx, loaderStatsContextKey{}, stats)
}

// GetLoaderStats 从上下文读取统计对象，不存在时返回空对象。
func GetLoaderStats(ctx context.Context) *LoaderStats {
	if stats, ok := ctx.Value(loaderStatsContextKey{}).(*LoaderStats); ok && stats != nil {
		return stats
	}
	return &LoaderStats{}
}

// NewDataLoaderOperationMiddleware 在每个 GraphQL 请求入口注入 loader。
func NewDataLoaderOperationMiddleware(client *ent.Client) graphql.OperationMiddleware {
	return func(ctx context.Context, next graphql.OperationHandler) graphql.ResponseHandler {
		stats := &LoaderStats{}
		requestCtx := WithLoaderStats(WithLoaders(ctx, NewLoaders(client, stats)), stats)
		responseHandler := next(requestCtx)
		return func(ctx context.Context) *graphql.Response {
			resp := responseHandler(ctx)
			if resp == nil {
				return nil
			}
			if resp.Extensions == nil {
				resp.Extensions = map[string]interface{}{}
			}
			resp.Extensions["unibo_loader_stats"] = stats.Snapshot()
			return resp
		}
	}
}

type parsedNodeKey struct {
	index int
	raw string
	id uuid.UUID
	table string
}

func batchLoadNodes(ctx context.Context, client *ent.Client, keys []string) ([]ent.Noder, []error) {
	results := make([]ent.Noder, len(keys))
	errs := make([]error, len(keys))
	grouped := map[string][]parsedNodeKey{}
	untagged := make([]parsedNodeKey, 0)

	for idx, key := range keys {
		parsed, err := parseNodeLookupKey(idx, key)
		if err != nil {
			errs[idx] = err
			continue
		}
		if parsed.table == "" {
			untagged = append(untagged, parsed)
			continue
		}
		grouped[parsed.table] = append(grouped[parsed.table], parsed)
	}

	for table, items := range grouped {
		ids := make([]uuid.UUID, len(items))
		for i, item := range items {
			ids[i] = item.id
		}
		nodes, err := client.Noders(ctx, ids, ent.WithFixedNodeType(table))
		if err != nil {
			for _, item := range items {
				errs[item.index] = err
			}
			continue
		}
		for i, node := range nodes {
			item := items[i]
			if node == nil {
				errs[item.index] = fmt.Errorf("node not found: %s", item.raw)
				continue
			}
			results[item.index] = node
		}
	}

	for _, item := range untagged {
		node, err := findNodeWithoutType(ctx, client, item.id)
		if err != nil {
			errs[item.index] = err
			continue
		}
		results[item.index] = node
	}

	return results, errs
}

func parseNodeLookupKey(index int, raw string) (parsedNodeKey, error) {
	typeName, rawID := decodeNodeID(raw)
	id, err := uuid.Parse(strings.TrimSpace(rawID))
	if err != nil {
		return parsedNodeKey{}, fmt.Errorf("invalid node id %q: %w", raw, err)
	}
	return parsedNodeKey{
		index: index,
		raw:   raw,
		id:    id,
		table: nodeTypeToTable(typeName),
	}, nil
}

func decodeNodeID(raw string) (string, string) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return "", ""
	}
	if strings.Contains(trimmed, ":") {
		parts := strings.SplitN(trimmed, ":", 2)
		return strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1])
	}
	decoded, err := base64.StdEncoding.DecodeString(trimmed)
	if err != nil {
		return "", trimmed
	}
	decodedText := strings.TrimSpace(string(decoded))
	if strings.Contains(decodedText, ":") {
		parts := strings.SplitN(decodedText, ":", 2)
		return strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1])
	}
	return "", trimmed
}

func nodeTypeToTable(typeName string) string {
	switch strings.ToLower(strings.TrimSpace(typeName)) {
	case "hoteloffer":
		return "hotel_offers"
	case "flightoffer":
		return "flight_offers"
	case "vacationoffer":
		return "vacation_offers"
	case "trainoffer":
		return "train_offers"
	case "travelorder":
		return "travel_orders"
	case "travelfulfillment":
		return "travel_fulfillments"
	default:
		return ""
	}
}

var nodeTableCandidates = []string{
	"hotel_offers",
	"flight_offers",
	"vacation_offers",
	"train_offers",
	"travel_orders",
	"travel_fulfillments",
}

func findNodeWithoutType(ctx context.Context, client *ent.Client, id uuid.UUID) (ent.Noder, error) {
	var notFoundErr error
	for _, table := range nodeTableCandidates {
		node, err := client.Noder(ctx, id, ent.WithFixedNodeType(table))
		if err == nil {
			return node, nil
		}
		if ent.IsNotFound(err) {
			notFoundErr = err
			continue
		}
		return nil, err
	}
	if notFoundErr != nil {
		return nil, notFoundErr
	}
	return nil, fmt.Errorf("node not found: %s", id.String())
}
