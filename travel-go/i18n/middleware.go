package i18n

import (
	"context"
	"net/http"
	"strings"
)

type localeKey struct{}

// LocaleMiddleware 从 Accept-Language 头提取语言，注入 context
func LocaleMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		lang := "en" // 默认英文
		if accept := r.Header.Get("Accept-Language"); accept != "" {
			lang = strings.Split(accept, ",")[0]
			lang = strings.Split(lang, ";")[0]
			lang = strings.TrimSpace(lang)
		}
		ctx := context.WithValue(r.Context(), localeKey{}, lang)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// LangFromContext 从 context 中提取语言标识，默认返回 "en"
func LangFromContext(ctx context.Context) string {
	if lang, ok := ctx.Value(localeKey{}).(string); ok {
		return lang
	}
	return "en"
}
