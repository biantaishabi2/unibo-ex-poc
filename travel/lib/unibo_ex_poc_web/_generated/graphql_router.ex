defmodule UniboExPocWeb.Generated.GraphqlRouter do
  @moduledoc "GraphQL 路由宏（自动生成）"

  defmacro graphql_routes do
    quote do
      scope "/api" do
        pipe_through :api
        post "/graphql", UniboExPocWeb.GraphqlController, :execute
      end
    end
  end
end
