defmodule HospitalSchedulingWeb.Plugs.LoadAuthActor do
  @moduledoc """
  从认证来源解析 actor/current_user，并注入 GraphQL/BFF 运行时上下文。
  由 UniBO 自动生成，请勿手动编辑。
  """
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims, user} <- authenticate_user(token) do
      actor = HospitalSchedulingWeb.Graphql.ActorContext.from_auth_result(user, claims, conn)

      conn
      |> assign(:auth_claims, claims)
      |> assign(:current_user, user)
      |> assign(:actor, actor || user)
    else
      _ -> conn
    end
  end

  defp authenticate_user(token) do
    user_module = user_resource_module()

    with true <- Code.ensure_loaded?(AshAuthentication.Jwt),
         true <- Code.ensure_loaded?(AshAuthentication),
         true <- Code.ensure_loaded?(user_module),
         true <- function_exported?(AshAuthentication.Jwt, :verify, 2),
         true <- function_exported?(AshAuthentication, :subject_to_user, 3),
         {:ok, claims, _resource} <- apply(AshAuthentication.Jwt, :verify, [token, user_module]),
         %{"sub" => subject} <- claims,
         {:ok, user} <- apply(AshAuthentication, :subject_to_user, [subject, user_module, [authorize?: false]]) do
      {:ok, claims, user}
    else
      _ -> :skip
    end
  end

  defp user_resource_module do
    Module.concat([HospitalScheduling, Accounts, User])
  end
end
