# Workflow: data_source_refresh_flow — 数据源创建、配置更新、刷新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   refresh --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Spreadsheet.DataSource do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "spreadsheet_data_sources"
    repo UniboV4.Repo
  end

  graphql do
    type :spreadsheet_data_source

    queries do
      get :get_spreadsheet_data_source, :read
      list :list_spreadsheet_data_sources, :read
    end

    mutations do
      create :create_spreadsheet_data_source, :create
      update :update_spreadsheet_data_source, :update
      destroy :delete_spreadsheet_data_source, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :document_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:list, :pivot, :chart, :global_filter]
      public? true
    end
    attribute :source_model, :string do
      allow_nil? false
      public? true
    end
    attribute :domain_filter, :string do
      default "[]"
      public? true
    end
    attribute :fields, :string do
      default "[]"
      public? true
    end
    attribute :group_by, :string do
      default "[]"
      public? true
    end
    attribute :measures, :string do
      default "[]"
      public? true
    end
    attribute :sort_by, :string do
      default "[]"
      public? true
    end
    attribute :limit, :integer, public?: true
    attribute :refresh_interval, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :cached_row_count
    # TODO: 不支持的 calculation 表达式 :last_refreshed_at
  end

  relationships do
    belongs_to :document, UniboV4.Spreadsheet.SpreadsheetDocument do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:type, :source_model, :domain_filter, :fields, :group_by, :measures, :sort_by, :limit, :refresh_interval]
      argument :document_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:domain_filter, :fields, :group_by, :measures, :sort_by, :limit, :refresh_interval]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    action :refresh do
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
