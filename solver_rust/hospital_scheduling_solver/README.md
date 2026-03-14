# hospital_scheduling_solver

当前 crate 的定位是：

- 冻结 `input_snapshot` / `output_snapshot` 契约
- 承载 fixture、状态语义、explanation 输出
- 作为后续 CP-SAT backend 的 Rust 集成层

当前 `src/solver.rs` 中的求解逻辑只能视为：

- contract harness
- fixture runner
- 最小可测试骨架

它**不是** `#69` 的最终求解器实现，也不应继续按“Rust 启发式最终版”方向扩写。

后续目标：

- CP-SAT 作为真正求解后端
- Rust 保持契约层与集成边界
- Elixir 负责编排、落库和页面流程

当前 feature 约定：

- 默认不启用 `cp_sat_backend`
- 启用方式：`cargo test --features cp_sat_backend`
- 启用该 feature 时，需要本机已安装 OR-Tools，并按 `cp_sat` crate 约定提供搜索路径

当前环境探测结果：

- 默认 `cargo test` 可通过
- 使用官方 `v9.15` C++ 预编译包时，下面这组环境变量可通过编译与测试

```bash
ORTOOLS_PREFIX=/home/wangbo/.local/opt/ortools/v9.15.6755 \
LD_LIBRARY_PATH=/home/wangbo/.local/opt/ortools/v9.15.6755/lib \
LIBRARY_PATH=/home/wangbo/.local/opt/ortools/v9.15.6755/lib \
CXXFLAGS='-DOR_PROTO_DLL=' \
RUSTFLAGS='-L native=/home/wangbo/.local/opt/ortools/v9.15.6755/lib -Clink-arg=-lprotobuf' \
cargo test --features cp_sat_backend
```

- 关键兼容点：`cp_sat 0.3.3` 对接新版本 OR-Tools 头文件时，需要显式补 `OR_PROTO_DLL` 宏
- 当前 crate 已包含一个 feature-gated smoke test，用来验证 Rust binding 能真实调起最小 CP-SAT 模型
- 本地也可以直接运行脚本 [`scripts/test_cp_sat_backend.sh`](./scripts/test_cp_sat_backend.sh)
