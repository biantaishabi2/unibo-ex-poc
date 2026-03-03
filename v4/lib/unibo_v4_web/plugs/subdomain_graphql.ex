defmodule UniboV4Web.Plugs.SubdomainGraphql do
  @moduledoc """
  为每个子域生成独立的 Absinthe Plug 包装模块，
  绕过 Phoenix Router 对同一模块只能 forward 一次的限制。
  """

  # 子域映射由编译器自动生成
  @subdomains UniboV4Web.Generated.SubdomainGraphql.subdomains()

  for {name, schema} <- @subdomains do
    # GraphQL API Plug
    api_module = Module.concat([UniboV4Web.Plugs.SubdomainGraphql, Macro.camelize(to_string(name))])

    defmodule api_module do
      @behaviour Plug
      @impl true
      def init(opts), do: Absinthe.Plug.init(Keyword.put(opts, :schema, unquote(schema)))
      @impl true
      def call(conn, opts), do: Absinthe.Plug.call(conn, opts)
    end

    # GraphiQL Playground Plug
    ui_module = Module.concat([UniboV4Web.Plugs.SubdomainGraphiql, Macro.camelize(to_string(name))])

    defmodule ui_module do
      @behaviour Plug
      @impl true
      def init(opts) do
        opts
        |> Keyword.put(:schema, unquote(schema))
        |> Keyword.put(:interface, :playground)
        |> Absinthe.Plug.GraphiQL.init()
      end

      @impl true
      def call(conn, opts), do: Absinthe.Plug.GraphiQL.call(conn, opts)
    end
  end
end
