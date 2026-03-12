defmodule UniboExPocWeb.Plugs.LoadAuthActor do
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
         {:ok, claims, _resource} <- AshAuthentication.Jwt.verify(token, UniboExPoc.Accounts.User),
         %{"sub" => subject} <- claims,
         {:ok, user} <- AshAuthentication.subject_to_user(subject, UniboExPoc.Accounts.User, authorize?: false) do
      actor = UniboExPocWeb.Graphql.ActorContext.from_auth_result(user, claims, conn)

      conn
      |> assign(:auth_claims, claims)
      |> assign(:current_user, user)
      |> assign(:actor, actor || user)
    else
      _ -> conn
    end
  end
end
