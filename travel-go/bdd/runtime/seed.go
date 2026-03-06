package runtime

import (
	"context"
	"fmt"
	"strings"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// SeedContract 描述一个种子数据契约
type SeedContract struct {
	Module    string
	Contract  string
	EdgeClass string
}

// ParseContract 解析 contract 字符串（如 "create_order"）
// 按 _ 分割，最后一个词为 entity，前面为 action
func ParseContract(contract string) (action string, entity string) {
	parts := strings.Split(contract, "_")
	if len(parts) < 2 {
		return contract, ""
	}
	entity = parts[len(parts)-1]
	action = strings.Join(parts[:len(parts)-1], "_")
	return
}

// ExecuteSeedContract 执行种子契约
func ExecuteSeedContract(ctx context.Context, client *ent.Client, sc SeedContract, args map[string]interface{}) (interface{}, error) {
	// 根据 EdgeClass 分发到 create/read/update/delete
	return nil, fmt.Errorf("not implemented: %s", sc.Contract)
}
