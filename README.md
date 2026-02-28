# UniboExPoc

## 启动后端

- `mix setup`
- `mix phx.server`（或 `iex -S mix phx.server`）

## 验证 POC 自动生成链路

该项目当前的业务主链路使用手写 Ash DSL；同时保留一条可复现的自动链路验证：

`OFBiz XML -> UniBO IR -> Ash DSL`

在 `unibo_ex_poc` 目录执行：

```bash
scripts/verify_codegen_poc.sh
```

前置条件：

- 同级目录存在 `../unibo`（UniBO CLI Rust 项目）
- 同级目录存在 `../ofbiz`（含 `order-entitymodel.xml`）

可选环境变量：

- `UNIBO_ROOT`：指定 unibo 仓库路径
- `OFBIZ_ROOT`：指定 OFBiz 仓库路径
- `ORDER_XML`：指定自定义 XML 输入文件

## V1 收尾验收

在 `unibo_ex_poc` 目录执行：

```bash
scripts/verify_v1_closure.sh
```

该脚本会顺序执行：

1. `scripts/verify_codegen_poc.sh`（验证 XML 导入 + 编译链路）
2. `mix test`（验证 PoC 后端行为）
