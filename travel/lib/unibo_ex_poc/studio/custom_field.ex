# Workflow: custom_field_lifecycle — 自定义字段生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> archive
#   create --> destroy
#   update --> activate
#   update --> archive
#   update --> destroy
#   activate --> update
#   activate --> archive
#   archive --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Studio.CustomField do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用户自定义字段，支持 20 种字段类型和计算字段公式系统"
  end

  postgres do
    table "studio_custom_fields"
    repo UniboExPoc.Repo
  end

  graphql do
    type :studio_custom_field

    queries do
      get :get_studio_custom_field, :read
      list :list_studio_custom_fields, :read
    end

    mutations do
      create :create_studio_custom_field, :create
      update :update_studio_custom_field, :update
      update :activate_studio_custom_field, :activate
      update :archive_studio_custom_field, :archive
      destroy :delete_studio_custom_field, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "字段技术名，必须以 x_ 前缀开头"
    end
    attribute :label, :string do
      allow_nil? false
      public? true
      description "字段显示标签"
    end
    attribute :field_type, :atom do
      allow_nil? false
      constraints one_of: [:string, :text, :integer, :float, :decimal, :boolean, :date, :datetime, :selection, :currency, :email, :url, :phone, :multi_select, :html, :json, :computed, :many2one, :one2many, :many2many, :binary]
      public? true
      description "字段类型，共 20 种"
    end
    attribute :required, :boolean do
      default false
      public? true
      description "是否必填"
    end
    attribute :readonly, :boolean do
      default false
      public? true
      description "是否只读"
    end
    attribute :default_value, :string do
      public? true
      description "类型安全的默认值"
    end
    attribute :selection_options, :string do
      public? true
      description "选择项列表，格式 [{\"value\":\"...\", \"label\":\"...\"}]"
    end
    attribute :related_field_name, :string do
      public? true
      description "反向关联字段名"
    end
    attribute :compute_formula, :string do
      public? true
      description "计算公式表达式"
    end
    attribute :compute_dependencies, :string do
      public? true
      description "公式依赖字段列表"
    end
    attribute :validation_rules, :string do
      public? true
      description "校验规则配置，如 {\"min\":0, \"max\":100, \"regex\":\"...\"}"
    end
    attribute :widget_hint, :string do
      public? true
      description "前端组件提示，映射到 WidgetRegistry"
    end
    attribute :sequence, :integer do
      public? true
      description "字段排序"
    end
    attribute :column_name, :string do
      public? true
      description "实际数据库列名"
    end
    attribute :is_indexed, :boolean do
      default false
      public? true
      description "是否创建数据库索引"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :active, :archived]
      default :draft
      public? true
      description "字段状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :model, UniboExPoc.Studio.CustomModel do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :related_model, UniboExPoc.Studio.CustomModel do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :label, :field_type, :required, :readonly, :default_value, :selection_options, :related_model_id, :related_field_name, :compute_formula, :compute_dependencies, :validation_rules, :widget_hint, :sequence, :is_indexed]
      argument :model_id, :integer, allow_nil?: false
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      validate match(:name, ~r/^x_/ )
      # message: "字段技术名必须以 x_ 开头"
      validate present(:name)
      validate present(:label)
      validate present(:field_type)
      validate present(:related_model_id)
      # message: "关系字段必须指定关联目标模型"
      validate present(:compute_formula)
      # message: "计算字段必须填写计算公式"
      validate present(:selection_options)
      # message: "选择字段必须至少包含一个选项"
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
      accept [:label, :required, :readonly, :default_value, :selection_options, :validation_rules, :widget_hint, :sequence]
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
    update :activate do
      description "激活字段，执行 DDL"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以激活"
      change set_attribute(:state, :active)
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
    update :archive do
      description "停用字段"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态可以停用"
      change set_attribute(:state, :archived)
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
  end

  identities do
    identity :unique_model_field_name, [:model_id, :name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
