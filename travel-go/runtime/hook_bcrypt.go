package runtime

import (
	"context"

	"entgo.io/ent"
	"golang.org/x/crypto/bcrypt"
)

// BcryptPasswordHook 返回一个 ent mutation hook，在写入前自动对 hashed_password 字段做 bcrypt 哈希。
func BcryptPasswordHook() ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
			if pw, exists := m.Field("hashed_password"); exists {
				hashed, err := bcrypt.GenerateFromPassword([]byte(pw.(string)), bcrypt.DefaultCost)
				if err != nil {
					return nil, err
				}
				if err := m.SetField("hashed_password", string(hashed)); err != nil {
					return nil, err
				}
			}
			return next.Mutate(ctx, m)
		})
	}
}
