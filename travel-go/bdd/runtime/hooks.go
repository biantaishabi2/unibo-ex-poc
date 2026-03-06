package runtime

import (
	"context"
	"database/sql"
)

// TestDB 保持测试数据库连接
var TestDB *sql.DB

// TestTx 当前事务（每个场景一个）
var TestTx *sql.Tx

// SetupSuite 初始化测试数据库连接
func SetupSuite(dsn string) error {
	var err error
	TestDB, err = sql.Open("postgres", dsn)
	return err
}

// BeforeScenario 开始事务
func BeforeScenario(ctx context.Context) (context.Context, error) {
	var err error
	TestTx, err = TestDB.Begin()
	if err != nil {
		return ctx, err
	}
	return ctx, nil
}

// AfterScenario 回滚事务（测试隔离）
func AfterScenario(ctx context.Context, err error) (context.Context, error) {
	if TestTx != nil {
		TestTx.Rollback()
		TestTx = nil
	}
	return ctx, nil
}
