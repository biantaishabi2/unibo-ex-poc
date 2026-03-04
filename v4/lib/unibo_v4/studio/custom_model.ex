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
defmodule UniboV4.Studio.CustomModel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Studio.CustomModel.Notifier]

  postgres do
    table "studio_custom_models"
    repo UniboV4.Repo
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
    attribute :technical_name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :table_name, :string do
      allow_nil? false
      public? true
    end
    attribute :is_abstract, :boolean do
      default false
      public? true
    end
    attribute :icon, :string, public?: true
    attribute :menu_sequence, :integer, public?: true
    attribute :state, :atom do
      constraints one_of: [:draft, :active, :archived]
      default :draft
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :inherits_model, UniboV4.Studio.CustomModel do
      public? true
      attribute_type :integer
    end
    belongs_to :created_by, UniboV4.Studio.User do
      public? true
    end
    has_many :fields, UniboV4.Studio.CustomField do
      public? true
      destination_attribute :model_id
    end
    has_many :views, UniboV4.Studio.CustomView do
      public? true
      destination_attribute :model_id
    end
    has_many :automation_rules, UniboV4.Studio.AutomationRule do
      public? true
      destination_attribute :model_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :technical_name, :description, :is_abstract, :icon, :menu_sequence]
      argument :inherits_model_id, :integer
      # TODO: 不支持的 action 内校验规则 format
      validate present(:name)
      validate present(:technical_name)
      # TODO: 跨实体聚合表达式暂不支持
      change relate_actor(:created_by)
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
      accept [:name, :description, :icon, :menu_sequence]
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
    update :reactivate do
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
    destroy :destroy do
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_technical_name, [:technical_name]
  end

end
