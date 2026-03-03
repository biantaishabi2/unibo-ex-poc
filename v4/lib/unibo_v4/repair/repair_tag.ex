# Workflow: repair_tag_maintain_flow — 标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Repair.RepairTag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "repair_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :repair_repair_tag

    queries do
      get :get_repair_repair_tag, :read
      list :list_repair_repair_tags, :read
    end

    mutations do
      create :create_repair_repair_tag, :create
      update :update_repair_repair_tag, :update
      destroy :delete_repair_repair_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :repair_tickets, UniboV4.Repair.RepairTicket do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :color]
      validate present(:name)
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
      accept [:name, :color]
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

  validations do
    # TODO: 不支持的校验规则 unique
  end

  identities do
    identity :unique_tag_name, [:name]
  end

end
