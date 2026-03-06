package runtime

import (
	"context"

	"entgo.io/ent"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/middleware"
)

// RelateActorHook 返回一个全局 mutation hook，自动将当前认证用户关联到 created_by/updated_by 字段。
// Create 操作设置 created_by 和 updated_by，Update 操作仅设置 updated_by。
func RelateActorHook() ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
			user := middleware.UserFromContext(ctx)
			if user == nil {
				return next.Mutate(ctx, m)
			}

			if setter, ok := m.(interface{ SetCreatedBy(string) }); ok && m.Op().Is(ent.OpCreate) {
				setter.SetCreatedBy(user.UserID)
			}
			if setter, ok := m.(interface{ SetUpdatedBy(string) }); ok {
				setter.SetUpdatedBy(user.UserID)
			}

			return next.Mutate(ctx, m)
		})
	}
}
