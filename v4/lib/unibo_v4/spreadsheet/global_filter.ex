# Workflow: global_filter_apply_flow — 全局筛选器创建、更新、应用与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   apply_filter --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Spreadsheet.GlobalFilter do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "spreadsheet_global_filters"
    repo UniboV4.Repo
  end

  graphql do
    type :spreadsheet_global_filter

    queries do
      get :get_spreadsheet_global_filter, :read
      list :list_spreadsheet_global_filters, :read
    end

    mutations do
      create :create_spreadsheet_global_filter, :create
      update :update_spreadsheet_global_filter, :update
      destroy :delete_spreadsheet_global_filter, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:relation, :date, :text, :boolean]
      public? true
    end
    attribute :source_model, :string, public?: true
    attribute :default_value, :string, public?: true
    attribute :range_type, :atom do
      constraints one_of: [:year, :quarter, :month, :week, :day]
      public? true
    end
    attribute :field_matchings, :string do
      allow_nil? false
      default "{}"
      public? true
    end
    create_timestamp :inserted_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :current_value
    # TODO: 不支持的 calculation 表达式 :matched_data_source_count
  end

  relationships do
    belongs_to :document, UniboV4.Spreadsheet.SpreadsheetDocument do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :type, :source_model, :default_value, :range_type, :field_matchings]
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
      accept [:name, :default_value, :field_matchings]
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
    action :apply_filter do
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  identities do
    identity :unique_filter_name_per_document, [:document_id, :name]
  end

end
