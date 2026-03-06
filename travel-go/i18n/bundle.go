package i18n

import (
	"embed"
	"encoding/json"

	"github.com/nicksnyder/go-i18n/v2/i18n"
	"golang.org/x/text/language"
)

//go:embed locales/*.json
var localeFS embed.FS

// Bundle 是全局的 i18n 消息 Bundle
var Bundle *i18n.Bundle

// Init 初始化 i18n Bundle，加载内嵌的 locale 文件
func Init() {
	Bundle = i18n.NewBundle(language.English)
	Bundle.RegisterUnmarshalFunc("json", json.Unmarshal)
	// 加载所有 locale 文件
	Bundle.LoadMessageFileFS(localeFS, "locales/en.json")
	Bundle.LoadMessageFileFS(localeFS, "locales/zh.json")
}

// Localize 根据语言和消息 ID 返回翻译文本，找不到时返回 messageID 本身
func Localize(lang string, messageID string) string {
	loc := i18n.NewLocalizer(Bundle, lang)
	msg, err := loc.Localize(&i18n.LocalizeConfig{MessageID: messageID})
	if err != nil {
		return messageID
	}
	return msg
}
