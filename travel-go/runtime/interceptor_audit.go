package runtime

import (
	"context"
	"fmt"
	"time"

	"entgo.io/ent"
)

// AuditLog represents a single audit trail entry.
type AuditLog struct {
	EntityType string
	EntityID   string
	Action     string
	ChangedBy  string
	ChangedAt  time.Time
	Changes    map[string]interface{}
}

// AuditInterceptor logs mutations to the audit trail.
type AuditInterceptor struct {
	logs []AuditLog
}

// NewAuditInterceptor creates a new audit interceptor.
func NewAuditInterceptor() *AuditInterceptor {
	return &AuditInterceptor{}
}

// Intercept implements the ent.Interceptor interface for queries (no-op for audit).
func (a *AuditInterceptor) Intercept(next ent.Querier) ent.Querier {
	return next
}

// Hook returns a mutation hook that records audit entries.
func (a *AuditInterceptor) Hook() ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
			// Record before mutation
			entry := AuditLog{
				EntityType: m.Type(),
				Action:     m.Op().String(),
				ChangedAt:  time.Now(),
				Changes:    make(map[string]interface{}),
			}

			// Capture changed fields
			for _, field := range m.Fields() {
				if v, exists := m.Field(field); exists {
					entry.Changes[field] = v
				}
			}

			// Execute mutation
			v, err := next.Mutate(ctx, m)
			if err != nil {
				return v, err
			}

			// Log the audit entry
			a.logs = append(a.logs, entry)
			fmt.Printf("[audit] %s %s: %v\n", entry.Action, entry.EntityType, entry.Changes)

			return v, nil
		})
	}
}
