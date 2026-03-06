package graph

import (
	"context"

	"github.com/99designs/gqlgen/graphql"
)

// NewFieldMiddleware 返回一个 AroundFields 中间件，用于字段级过滤/转换
func NewFieldMiddleware() graphql.FieldMiddleware {
	return func(ctx context.Context, next graphql.Resolver) (interface{}, error) {
		fc := graphql.GetFieldContext(ctx)
		_ = fc // 可在此添加字段级过滤/转换逻辑
		return next(ctx)
	}
}
