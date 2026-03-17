ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(UniboExPoc.Repo, :manual)

# 启动 AsyncRuntime.Store（BDD integration bridge 测试需要）
UniboExPoc.AsyncRuntime.Store.start_link([])
