# Workflow: ticket_type_management — 工单类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Helpdesk.HelpdeskTicketType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_ticket_types"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tickets, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      destination_attribute :ticket_type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence]
      validate present(:name)
      # message: "类型名称必填"
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
      accept [:name, :description, :sequence, :active]
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
    identity :unique_ticket_type_name, [:name]
  end

end
