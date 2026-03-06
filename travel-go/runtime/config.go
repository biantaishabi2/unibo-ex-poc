package runtime

import (
	"log"
	"strings"

	"github.com/spf13/viper"
)

// RuntimeConfig 运行时配置
type RuntimeConfig struct {
	// Profile 运行模式：strict（严格模式）或 compat（兼容模式）
	Profile string `mapstructure:"profile"`
	// Debug 是否开启调试日志
	Debug bool `mapstructure:"debug"`
}

// LoadConfig 从环境变量和配置文件加载运行时配置
// 环境变量前缀为 UNIBO_，如 UNIBO_PROFILE=strict, UNIBO_DEBUG=true
func LoadConfig() *RuntimeConfig {
	v := viper.New()

	// 设置默认值
	v.SetDefault("profile", "strict")
	v.SetDefault("debug", false)

	// 从环境变量读取
	v.SetEnvPrefix("UNIBO")
	v.AutomaticEnv()
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// 尝试从配置文件读取（可选）
	v.SetConfigName("unibo")
	v.SetConfigType("yaml")
	v.AddConfigPath(".")
	v.AddConfigPath("./config")

	if err := v.ReadInConfig(); err != nil {
		// 配置文件不存在不是错误，使用默认值
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			log.Printf("warning: error reading config file: %v", err)
		}
	}

	cfg := &RuntimeConfig{}
	if err := v.Unmarshal(cfg); err != nil {
		log.Printf("warning: failed to unmarshal config: %v, using defaults", err)
		cfg = &RuntimeConfig{
			Profile: "strict",
			Debug:   false,
		}
	}

	// 验证 profile 值
	switch cfg.Profile {
	case "strict", "compat":
		// 合法值
	default:
		log.Printf("warning: unknown profile %q, falling back to strict", cfg.Profile)
		cfg.Profile = "strict"
	}

	return cfg
}
