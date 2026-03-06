package graph

import (
	"github.com/99designs/gqlgen/graphql"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// Resolver is the resolver root.
type Resolver struct {
	Client *ent.Client
}

// NewSchema creates a graphql executable schema.
// NewExecutableSchema 和 Config 由 gqlgen 在 go generate 阶段生成。
func NewSchema(client *ent.Client) graphql.ExecutableSchema {
	cfg := Config{
			Resolvers: &Resolver{Client: client},
		}
	// 显式绑定 directive handler，避免运行时遗漏指令实现。
	cfg.Directives.HasRole = HasRoleDirective
	cfg.Directives.Abac = ABACDirective
	cfg.Directives.Sensitive = SensitiveDirective
	return NewExecutableSchema(cfg)
}
