package runtime

import (
	"fmt"
	"time"
)

// Get 从 ctx map 中获取值
func Get(ctx map[string]interface{}, key string) interface{} {
	return ctx[key]
}

// GetString 从 ctx map 中获取字符串值
func GetString(ctx map[string]interface{}, key string) string {
	v, ok := ctx[key].(string)
	if !ok {
		return ""
	}
	return v
}

// Now 返回当前时间
func Now() time.Time {
	return time.Now()
}

// ParseDatetime 解析日期时间字符串
func ParseDatetime(s string) (time.Time, error) {
	layouts := []string{
		time.RFC3339,
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
		"2006-01-02",
	}
	for _, layout := range layouts {
		if t, err := time.Parse(layout, s); err == nil {
			return t, nil
		}
	}
	return time.Time{}, fmt.Errorf("cannot parse datetime: %s", s)
}

// ParseDate 解析日期字符串
func ParseDate(s string) (time.Time, error) {
	return time.Parse("2006-01-02", s)
}

// EnsureActor 确保 ctx 中有 actor（用于 relate_actor 策略）
func EnsureActor(ctx map[string]interface{}, actorID interface{}) {
	ctx["__actor_id__"] = actorID
}
