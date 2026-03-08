# Workflow: custom_model_lifecycle — 自定义模型生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> destroy
#   update --> activate
#   update --> destroy
#   activate --> update
#   activate --> archive
#   archive --> reactivate
#   archive --> destroy
#   reactivate --> update
#   reactivate --> archive
#   destroy --> [*]
# ```
defmodule UniboExPoc.Studio.CustomModel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Studio.CustomModel.Notifier]

  resource do
    description "用户自定义数据模型，运行时动态建表"
  end

  postgres do
    table "studio_custom_models"
    repo UniboExPoc.Repo
  end

  graphql do
    type :studio_custom_model

    queries do
      get :get_studio_custom_model, :read
      list :list_studio_custom_models, :read
    end

    mutations do
      create :create_studio_custom_model, :create
      update :update_studio_custom_model, :update
      update :activate_studio_custom_model, :activate
      update :archive_studio_custom_model, :archive
      update :reactivate_studio_custom_model, :reactivate
      destroy :delete_studio_custom_model, :destroy
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
      description "模型显示名称"
    end
    attribute :technical_name, :string do
      allow_nil? false
      public? true
      description "技术名，必须以 x_ 前缀开头"
    end
    attribute :description, :string do
      public? true
      description "模型说明"
    end
    attribute :table_name, :string do
      allow_nil? false
      public? true
      description "自动生成的数据库表名，格式 studio_x_{technical_name}"
    end
    attribute :is_abstract, :boolean do
      default false
      public? true
      description "抽象模型不创建物理表，仅作为字段继承基础"
    end
    attribute :icon, :string do
      public? true
      description "模型图标"
    end
    attribute :menu_sequence, :integer do
      public? true
      description "菜单排序"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :active, :archived]
      default :draft
      public? true
      description "模型状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inherits_model, UniboExPoc.Studio.CustomModel do
      public? true
      attribute_type :integer
    end
    belongs_to :created_by, UniboExPoc.Studio.Party do
      public? true
      source_attribute :created_by_party_id
    end
    has_many :fields, UniboExPoc.Studio.CustomField do
      public? true
      source_attribute :inherits_model_id
      destination_attribute :model_id
    end
    has_many :views, UniboExPoc.Studio.CustomView do
      public? true
      source_attribute :inherits_model_id
      destination_attribute :model_id
    end
    has_many :automation_rules, UniboExPoc.Studio.AutomationRule do
      public? true
      source_attribute :inherits_model_id
      destination_attribute :model_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :technical_name, :description, :is_abstract, :icon, :menu_sequence]
      argument :inherits_model_id, :integer
      validate match(:technical_name, ~r/^x_/ )
      # message: "技术名必须以 x_ 开头，以区分系统模型与用户自定义模型"
      validate present(:name)
      validate present(:technical_name)
      change UniboExPoc.Studio.Changes.CustomModel.ComputeTableName
      change relate_actor(:created_by)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :icon, :menu_sequence]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "发布模型，执行 DDL 建表"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      change set_attribute(:state, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "停用模型"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reactivate do
      description "重新激活模型"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :archived do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :archived}))
        end
      end
      # message: "只有已停用状态可以重新激活"
      change set_attribute(:state, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除模型，级联清理字段、视图、自动化规则"
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_technical_name, [:technical_name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:fields, :views, :automation_rules]
  end

end
