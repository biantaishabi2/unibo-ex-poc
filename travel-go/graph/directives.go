package graph

import (
	"context"
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/middleware"
)

// HasRoleDirective 实现 @hasRole(roles: [...]) 指令，校验当前用户角色
func HasRoleDirective(ctx context.Context, obj interface{}, next graphql.Resolver, roles []string) (interface{}, error) {
	user := middleware.UserFromContext(ctx)
	if user == nil {
		return nil, middleware.ForbiddenErrorWithMessage("missing_actor_context", "missing actor context")
	}
	for _, role := range roles {
		if user.Role == role {
			return next(ctx)
		}
	}
	return nil, middleware.ForbiddenErrorWithMessage("insufficient_role", fmt.Sprintf("insufficient permissions: required one of %v", roles))
}

// ABACDirective 实现 @abac(rule: "...") 指令，支持 actor/data/tenant 组合校验。
func ABACDirective(ctx context.Context, obj interface{}, next graphql.Resolver, rule string) (interface{}, error) {
	allowed, reason, err := middleware.EvaluateFieldABAC(ctx, obj, rule)
	if err != nil {
		return nil, middleware.ForbiddenErrorWithMessage("invalid_abac_rule", err.Error())
	}
	if !allowed {
		return nil, middleware.ForbiddenErrorWithMessage(reason, "abac access denied")
	}
	return next(ctx)
}

// SensitiveDirective 实现 @sensitive 指令，匿名用户看到脱敏值
func SensitiveDirective(ctx context.Context, obj interface{}, next graphql.Resolver) (interface{}, error) {
	user := middleware.UserFromContext(ctx)
	if user == nil {
		return "***", nil
	}
	return next(ctx)
}
