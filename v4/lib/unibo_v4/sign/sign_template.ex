# Workflow: sign_template_write_flow — 签名模板写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   archive --> [*]
#   activate --> [*]
# ```
defmodule UniboV4.Sign.SignTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sign_templates"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :document, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:active, :archived]
      default :active
      public? true
    end
    attribute :tag_ids, {:array, :string}, public?: true
    attribute :is_sharing, :boolean do
      default false
      public? true
    end
    attribute :authorized_ids, {:array, :string}, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :num_pages
    calculate :sign_item_count, :integer, expr(count(sign_items, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :responsible, UniboV4.Sign.User do
      public? true
    end
    has_many :sign_items, UniboV4.Sign.SignItem do
      public? true
      destination_attribute :template_id
    end
    has_many :sign_requests, UniboV4.Sign.SignRequest do
      public? true
      destination_attribute :template_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :document, :tag_ids, :is_sharing, :authorized_ids]
      argument :responsible_id, :uuid
      argument :sign_items, {:array, :string}
      change manage_relationship(:sign_items, :sign_items, type: :create)
      validate present(:name)
      validate present(:document)
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
      accept [:name, :document, :tag_ids, :is_sharing, :authorized_ids]
      argument :sign_items, {:array, :map}, default: []
      change manage_relationship(:sign_items, :sign_items, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态可以归档"
      change set_attribute(:status, :archived)
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
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :archived do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :archived}))
        end
      end
      # message: "只有已归档状态可以启用"
      change set_attribute(:status, :active)
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

end
