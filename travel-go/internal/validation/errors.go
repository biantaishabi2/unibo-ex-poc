package validation

import (
	"fmt"
	"strings"
)

// ValidationError 表示单个字段的验证错误
type ValidationError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
	Code    string `json:"code"`
}

// ValidationErrors 表示多个验证错误的集合
type ValidationErrors []ValidationError

// Error 实现 error 接口，格式化所有验证错误
func (e ValidationErrors) Error() string {
	if len(e) == 0 {
		return ""
	}
	msgs := make([]string, len(e))
	for i, err := range e {
		msgs[i] = fmt.Sprintf("[%s] %s (code: %s)", err.Field, err.Message, err.Code)
	}
	return "validation failed: " + strings.Join(msgs, "; ")
}

// HasErrors 返回是否包含错误
func (e ValidationErrors) HasErrors() bool {
	return len(e) > 0
}

// ForField 返回指定字段的所有错误
func (e ValidationErrors) ForField(field string) ValidationErrors {
	var result ValidationErrors
	for _, err := range e {
		if err.Field == field {
			result = append(result, err)
		}
	}
	return result
}
