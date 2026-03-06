package runtime

import (
	"context"
	"fmt"
)

// StepFunc 是步骤执行函数签名
type StepFunc func(ctx context.Context, args map[string]interface{}) error

// Registry 存储已注册的步骤处理函数
var registry = map[string]StepFunc{}

// Register 注册一个步骤处理函数
func Register(name string, fn StepFunc) {
	registry[name] = fn
}

// RunStep 统一步骤分发（等价 Elixir CommonInstructions.run!/6）
func RunStep(ctx context.Context, kind string, name string, args map[string]interface{}) error {
	key := name
	fn, ok := registry[key]
	if !ok {
		return fmt.Errorf("unknown step: %s (kind=%s)", name, kind)
	}
	return fn(ctx, args)
}
