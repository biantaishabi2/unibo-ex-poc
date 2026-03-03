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
defmodule UniboV4.Studio.CustomField do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "studio_custom_fields"
    repo UniboV4.Repo
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
      public? true
    end
    attribute :model_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :label, :string do
      allow_nil? false
      public? true
    end
    attribute :field_type, :atom do
      allow_nil? false
      constraints one_of: [:string, :text, :integer, :float, :decimal, :boolean, :date, :datetime, :selection, :currency, :email, :url, :phone, :multi_select, :html, :json, :computed, :many2one, :one2many, :many2many, :binary]
      public? true
    end
    attribute :required, :boolean do
      default false
      public? true
    end
    attribute :readonly, :boolean do
      default false
      public? true
    end
    attribute :default_value, :string, public?: true
    attribute :selection_options, :string, public?: true
    attribute :related_model_id, :integer, public?: true
    attribute :related_field_name, :string, public?: true
    attribute :compute_formula, :string, public?: true
    attribute :compute_dependencies, :string, public?: true
    attribute :validation_rules, :string, public?: true
    attribute :widget_hint, :string, public?: true
    attribute :sequence, :integer, public?: true
    attribute :column_name, :string, public?: true
    attribute :is_indexed, :boolean do
      default false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :active, :archived]
      default :draft
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :model, UniboV4.Studio.CustomModel do
      public? true
      allow_nil? false
    end
    belongs_to :related_model, UniboV4.Studio.CustomModel do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :label, :field_type, :required, :readonly, :default_value, :selection_options, :related_model_id, :related_field_name, :compute_formula, :compute_dependencies, :validation_rules, :widget_hint, :sequence, :is_indexed]
      argument :model_id, :integer, allow_nil?: false
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 format
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

end
