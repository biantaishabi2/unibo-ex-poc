package runtime

import (
	"context"
	"fmt"
	"time"

	"entgo.io/ent"
	"entgo.io/ent/dialect/sql"
)

// SoftDeleteInterceptor filters queries to exclude soft-deleted records
// and converts delete operations to soft deletes.
type SoftDeleteInterceptor struct{}

// Intercept adds WHERE deleted_at IS NULL to all queries.
func (SoftDeleteInterceptor) Intercept(next ent.Querier) ent.Querier {
	return ent.QuerierFunc(func(ctx context.Context, query ent.Query) (ent.Value, error) {
		// Skip filter if context explicitly includes deleted
		if SkipSoftDelete(ctx) {
			return next.Query(ctx, query)
		}
		// Add soft delete filter
		if q, ok := query.(interface {
			WhereP(...func(*sql.Selector))
		}); ok {
			q.WhereP(func(s *sql.Selector) {
				s.Where(sql.IsNull(s.C("deleted_at")))
			})
		}
		return next.Query(ctx, query)
	})
}

// Hook converts delete mutations to soft deletes (sets deleted_at).
func (SoftDeleteInterceptor) Hook() ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
			if m.Op() == ent.OpDelete || m.Op() == ent.OpDeleteOne {
				// Convert delete to update with deleted_at
				if setter, ok := m.(interface {
					SetDeletedAt(time.Time)
				}); ok {
					setter.SetDeletedAt(time.Now())
					fmt.Printf("[soft-delete] %s marked as deleted\n", m.Type())
				}
			}
			return next.Mutate(ctx, m)
		})
	}
}

type softDeleteKey struct{}

// WithIncludeDeleted returns a context that skips soft delete filtering.
func WithIncludeDeleted(ctx context.Context) context.Context {
	return context.WithValue(ctx, softDeleteKey{}, true)
}

// SkipSoftDelete checks if the context should skip soft delete filtering.
func SkipSoftDelete(ctx context.Context) bool {
	v, _ := ctx.Value(softDeleteKey{}).(bool)
	return v
}
