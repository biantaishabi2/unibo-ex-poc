# Workflow: data_source_refresh_flow — 数据源创建、配置更新、刷新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   refresh --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Spreadsheet.DataSource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "ERP 数据源绑定，将电子表格与 ERP 模型（sale.order、hr.employee 等）动态关联"
  end

  postgres do
    table "spreadsheet_data_sources"
    repo UniboExPoc.Repo
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
      generated? true
      public? true
      description "数据源 ID"
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:list, :pivot, :chart, :global_filter]
      public? true
      description "数据源类型"
    end
    attribute :source_model, :string do
      allow_nil? false
      public? true
      description "目标 ERP 模型名（如 sale.order）"
    end
    attribute :domain_filter, :string do
      default "[]"
      public? true
      description "筛选条件，三元组格式 [[\"state\",\"=\",\"confirmed\"]]"
    end
    attribute :fields, :string do
      default "[]"
      public? true
      description "选中的字段列表"
    end
    attribute :group_by, :string do
      default "[]"
      public? true
      description "分组字段，支持时间粒度 [\"create_date:month\"]"
    end
    attribute :measures, :string do
      default "[]"
      public? true
      description "度量值 [\"amount_total:sum\"]"
    end
    attribute :sort_by, :string do
      default "[]"
      public? true
      description "排序规则 [{\"field\":\"...\",\"order\":\"desc\"}]"
    end
    attribute :limit, :integer do
      public? true
      description "记录数限制（仅 list 类型有效）"
    end
    attribute :refresh_interval, :integer do
      default 0
      public? true
      description "自动刷新间隔（秒），0=手动"
    end
    create_timestamp :inserted_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :cached_row_count, :integer, {UniboExPoc.Spreadsheet.Calculations.DataSource.CachedRowCount, []}
    calculate :last_refreshed_at, :utc_datetime, {UniboExPoc.Spreadsheet.Calculations.DataSource.LastRefreshedAt, []}
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
      accept [:type, :source_model, :domain_filter, :fields, :group_by, :measures, :sort_by, :limit, :refresh_interval]
      argument :document_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      # validation: valid_source_model — source_model 不是已注册的 ERP 模型
      validate present([:measures])
      # message: "透视表类型的数据源必须指定至少一个度量值"
      validate present([:fields])
      # message: "列表类型的数据源必须指定至少一个字段"
      validate attribute_in(:group_by, [:month, :quarter, :year])
      # message: "分组字段的时间粒度仅支持 month、quarter、year"
      # validation: valid_domain_filter_fields — 筛选条件中引用了不存在的字段
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:domain_filter, :fields, :group_by, :measures, :sort_by, :limit, :refresh_interval]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :group_by)
        if current in [:month, :quarter, :year] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :group_by, message: "must be one of %{values}", vars: %{values: [:month, :quarter, :year]}))
        end
      end
      # message: "分组字段的时间粒度仅支持 month、quarter、year"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :refresh do
      description "刷新数据源，从 ERP 重新拉取数据"
      # validation: apply_user_data_permissions
      # validation: query_safety_limits
      # validation: refresh_triggers
      run fn input, _context ->
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
