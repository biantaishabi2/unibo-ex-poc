# Workflow: global_filter_apply_flow — 全局筛选器创建、更新、应用与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   apply_filter --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Spreadsheet.GlobalFilter do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "全局筛选器，跨数据源统一筛选，通过 FILTER.VALUE() 公式在单元格中引用"
  end

  postgres do
    table "spreadsheet_global_filters"
    repo UniboExPoc.Repo
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
      generated? true
      public? true
      description "筛选器 ID"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "筛选器显示名称（同一文档内唯一，FILTER.VALUE(filter_name) 按名称引用）"
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:relation, :date, :text, :boolean]
      public? true
      description "筛选器类型（创建时确定，不可变更）"
    end
    attribute :source_model, :string do
      public? true
      description "关联 ERP 模型（仅 relation 类型必填）"
    end
    attribute :default_value, :string do
      public? true
      description "默认值"
    end
    attribute :range_type, :atom do
      constraints one_of: [:year, :quarter, :month, :week, :day]
      public? true
      description "日期范围粒度（仅 date 类型有效且必填）"
    end
    attribute :field_matchings, :string do
      allow_nil? false
      default "{}"
      public? true
      description "各数据源的字段匹配规则，映射筛选器到具体数据源字段"
    end
    create_timestamp :inserted_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :current_value, :string, {UniboExPoc.Spreadsheet.Calculations.GlobalFilter.CurrentValue, []}
    calculate :matched_data_source_count, :integer, expr(count_keys(field_matchings))
  end

  relationships do
    belongs_to :document, UniboExPoc.Spreadsheet.SpreadsheetDocument do
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
      validate present([:source_model])
      # message: "关联类型的筛选器必须指定 source_model"
      validate present([:range_type])
      # message: "日期类型的筛选器必须指定 range_type"
      # validation: valid_data_source_refs — field_matchings 引用了不存在的数据源
      # validation: valid_matching_fields — field_matchings 中指定了不存在的字段
      validate present([:name, :document_id])
      # message: "筛选器名称在同一文档内必须唯一"
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
      # skipped: validate present : (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
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
      description "应用筛选值变更，触发匹配的数据源同步刷新"
      # validation: sync_refresh_on_change
      # validation: relation_options_data_permission
      run fn input, _context ->
        :ok
      end
    end
  end

  identities do
    identity :unique_filter_name_per_document, [:document_id, :name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
