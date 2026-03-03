defmodule UniboV4.BDD.AshIntrospector do
  @moduledoc false

  # 所有已注册的 Ash Domain 模块
  @domains [
    UniboV4.Accounting,
    UniboV4.Accounts,
    UniboV4.Approvals,
    UniboV4.Blog,
    UniboV4.Communication,
    UniboV4.CRM,
    UniboV4.Currency,
    UniboV4.DataRecycle,
    UniboV4.Documents,
    UniboV4.Ecommerce,
    UniboV4.ELearning,
    UniboV4.Expenses,
    UniboV4.Forum,
    UniboV4.Gamification,
    UniboV4.Helpdesk,
    UniboV4.HR,
    UniboV4.Inventory,
    UniboV4.IoT,
    UniboV4.Knowledge,
    UniboV4.LiveChat,
    UniboV4.Lunch,
    UniboV4.Maintenance,
    UniboV4.Manufacturing,
    UniboV4.Marketing,
    UniboV4.Membership,
    UniboV4.PLM,
    UniboV4.POS,
    UniboV4.Project,
    UniboV4.Purchasing,
    UniboV4.Quality,
    UniboV4.Rental,
    UniboV4.Sales,
    UniboV4.Sign,
    UniboV4.Spreadsheet,
    UniboV4.Studio,
    UniboV4.Subscriptions,
    UniboV4.Survey,
    UniboV4.Uom
  ]

  # BDD 域名 → Ash Domain 模块映射
  @domain_map %{
    "ACCOUNTING" => UniboV4.Accounting,
    "ACCOUNTS" => UniboV4.Accounts,
    "APPROVALS" => UniboV4.Approvals,
    "BLOG" => UniboV4.Blog,
    "COMMUNICATION" => UniboV4.Communication,
    "CRM" => UniboV4.CRM,
    "CURRENCY" => UniboV4.Currency,
    "DATA_RECYCLE" => UniboV4.DataRecycle,
    "DOCUMENTS" => UniboV4.Documents,
    "ECOMMERCE" => UniboV4.Ecommerce,
    "E_LEARNING" => UniboV4.ELearning,
    "EXPENSES" => UniboV4.Expenses,
    "FORUM" => UniboV4.Forum,
    "GAMIFICATION" => UniboV4.Gamification,
    "HELPDESK" => UniboV4.Helpdesk,
    "HR" => UniboV4.HR,
    "INVENTORY" => UniboV4.Inventory,
    "IO_T" => UniboV4.IoT,
    "KNOWLEDGE" => UniboV4.Knowledge,
    "LIVE_CHAT" => UniboV4.LiveChat,
    "LUNCH" => UniboV4.Lunch,
    "MAINTENANCE" => UniboV4.Maintenance,
    "MANUFACTURING" => UniboV4.Manufacturing,
    "MARKETING" => UniboV4.Marketing,
    "MEMBERSHIP" => UniboV4.Membership,
    "PLM" => UniboV4.PLM,
    "POS" => UniboV4.POS,
    "PROJECT" => UniboV4.Project,
    "PURCHASING" => UniboV4.Purchasing,
    "QUALITY" => UniboV4.Quality,
    "RENTAL" => UniboV4.Rental,
    "SALES" => UniboV4.Sales,
    "SIGN" => UniboV4.Sign,
    "SPREADSHEET" => UniboV4.Spreadsheet,
    "STUDIO" => UniboV4.Studio,
    "SUBSCRIPTIONS" => UniboV4.Subscriptions,
    "SURVEY" => UniboV4.Survey,
    "UOM" => UniboV4.Uom
  }

  @doc """
  从 BDD 域名和实体名解析出 Ash Resource 模块。
  例: resolve_resource("ACCOUNTING", "BILLING_ACCOUNT") → {:ok, UniboV4.Accounting.BillingAccount}
  """
  def resolve_resource(domain, entity) do
    case Map.get(@domain_map, domain) do
      nil ->
        {:error, :domain_not_implemented}

      domain_mod ->
        entity_module_name = entity_to_module_name(entity)
        resource_mod = Module.concat(domain_mod, entity_module_name)

        if Code.ensure_loaded?(resource_mod) do
          {:ok, resource_mod}
        else
          # 尝试在 domain 资源列表中模糊匹配
          case find_resource_in_domain(domain_mod, entity) do
            {:ok, _} = ok -> ok
            :error -> {:error, :resource_not_found}
          end
        end
    end
  end

  @doc """
  解析 contract 字符串。
  例: "BillingAccount.create action contract (risk:success)"
    → %{entity: "BillingAccount", action: "create", edge_type: "action", risk: "success"}

  "Article.article_lifecycle workflow contract (risk:mainline)"
    → %{entity: "Article", action: "article_lifecycle", edge_type: "workflow", risk: "mainline"}
  """
  def parse_contract(contract) when is_binary(contract) do
    # 匹配: Entity.action_name edge_type contract [(risk:risk_type)]
    regex = ~r/^(\w+)\.(\w+)\s+(action|event|workflow)\s+contract(?:\s+\(risk:(\w+)\))?$/

    case Regex.run(regex, contract) do
      [_, entity, action, edge_type] ->
        %{entity: entity, action: action, edge_type: edge_type, risk: nil}

      [_, entity, action, edge_type, risk] ->
        %{entity: entity, action: action, edge_type: edge_type, risk: risk}

      _ ->
        %{entity: nil, action: nil, edge_type: nil, risk: nil}
    end
  end

  @doc """
  查找 resource 上指定名称的 action。
  """
  def find_action(resource, action_name) when is_atom(action_name) do
    Ash.Resource.Info.action(resource, action_name)
  end

  def find_action(resource, action_name) when is_binary(action_name) do
    find_action(resource, String.to_atom(action_name))
  end

  @doc """
  获取 resource 的所有 required 属性（allow_nil? == false 且没有默认值的）。
  """
  def required_attributes(resource) do
    resource
    |> Ash.Resource.Info.attributes()
    |> Enum.filter(fn attr ->
      not attr.allow_nil? and
        is_nil(attr.default) and
        attr.name not in [:id, :inserted_at, :updated_at] and
        not attr.primary_key?
    end)
  end

  @doc """
  获取 action 接受的属性名列表。
  """
  def action_accept(resource, action_name) when is_atom(action_name) do
    case find_action(resource, action_name) do
      nil -> []
      action -> action.accept || []
    end
  end

  @doc """
  获取 action 的类型 (:create, :read, :update, :destroy)。
  """
  def action_type(resource, action_name) when is_atom(action_name) do
    case find_action(resource, action_name) do
      nil -> nil
      action -> action.type
    end
  end

  @doc """
  检查 action 是否需要 actor（通过 relate_actor 或 policies）。
  """
  def uses_actor?(resource, action_name) when is_atom(action_name) do
    case find_action(resource, action_name) do
      nil ->
        false

      action ->
        has_relate_actor =
          Enum.any?(action.changes, fn
            %{change: {Ash.Resource.Change.RelateActor, _}} -> true
            _ -> false
          end)

        has_policies =
          case Ash.Resource.Info.authorizers(resource) do
            [] -> false
            _ -> true
          end

        has_relate_actor or has_policies
    end
  end

  @doc """
  获取 resource 的所有 belongs_to 关系。
  """
  def belongs_to_relationships(resource) do
    resource
    |> Ash.Resource.Info.relationships()
    |> Enum.filter(&(&1.type == :belongs_to))
  end

  @doc """
  获取 resource 需要的 belongs_to 依赖（非可空的）。
  """
  def required_belongs_to(resource) do
    resource
    |> belongs_to_relationships()
    |> Enum.reject(& &1.allow_nil?)
  end

  @doc """
  获取所有 Ash Domain 模块。
  """
  def domains, do: @domains

  @doc """
  获取域名映射。
  """
  def domain_map, do: @domain_map

  # ============================================================
  # 内部辅助
  # ============================================================

  # "BILLING_ACCOUNT" → "BillingAccount"
  defp entity_to_module_name(entity) do
    entity
    |> String.split("_")
    |> Enum.map_join("", fn part ->
      part |> String.downcase() |> String.capitalize()
    end)
  end

  # 在 domain 的资源列表中模糊匹配实体名
  defp find_resource_in_domain(domain_mod, entity) do
    target = entity_to_module_name(entity)

    try do
      resources = Ash.Domain.Info.resources(domain_mod)

      found =
        Enum.find(resources, fn res ->
          res_name = res |> Module.split() |> List.last()
          res_name == target
        end)

      if found, do: {:ok, found}, else: :error
    rescue
      _ -> :error
    end
  end
end
