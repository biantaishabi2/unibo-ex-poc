package runtime

import (
	"context"

	"entgo.io/ent"
)

// ChangesetHook represents a single step in a changeset chain.
type ChangesetHook struct {
	Name string
	Fn   ent.Hook
}

// ChangesetChain executes multiple hooks in sequence.
// Each hook runs in order; if any fails, the chain stops.
func ChangesetChain(hooks ...ChangesetHook) ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		// Build chain from last to first
		chain := next
		for i := len(hooks) - 1; i >= 0; i-- {
			chain = hooks[i].Fn(chain)
		}
		return chain
	}
}

// Validate creates a ChangesetHook that validates a condition.
func Validate(name string, fn func(ctx context.Context, m ent.Mutation) error) ChangesetHook {
	return ChangesetHook{
		Name: name,
		Fn: func(next ent.Mutator) ent.Mutator {
			return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
				if err := fn(ctx, m); err != nil {
					return nil, err
				}
				return next.Mutate(ctx, m)
			})
		},
	}
}

// Normalize creates a ChangesetHook that transforms mutation data.
func Normalize(name string, fn func(ctx context.Context, m ent.Mutation) error) ChangesetHook {
	return ChangesetHook{
		Name: name,
		Fn: func(next ent.Mutator) ent.Mutator {
			return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
				if err := fn(ctx, m); err != nil {
					return nil, err
				}
				return next.Mutate(ctx, m)
			})
		},
	}
}
