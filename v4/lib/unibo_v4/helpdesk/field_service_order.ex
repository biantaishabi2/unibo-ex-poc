# Workflow: field_service_lifecycle — 现场服务任务生命周期（创建→排期→完成）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> schedule
#   create --> complete
#   schedule --> complete
#   complete --> [*]
# ```
defmodule UniboV4.Helpdesk.FieldServiceOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Helpdesk.FieldServiceOrder.Notifier]

  postgres do
    table "helpdesk_field_service_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :planned_date_begin, :utc_datetime, public?: true
    attribute :planned_date_end, :utc_datetime, public?: true
    attribute :is_done, :boolean do
      allow_nil? false
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :helpdesk_ticket, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
    end
    belongs_to :project, UniboV4.Helpdesk.Project do
      public? true
    end
    belongs_to :partner, UniboV4.Helpdesk.Partner do
      public? true
    end
    belongs_to :user, UniboV4.Helpdesk.User do
      public? true
    end
    many_to_many :tag_ids, UniboV4.Helpdesk.Tag do
      public? true
      through UniboV4.Helpdesk.FieldServiceOrderTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :planned_date_begin, :planned_date_end]
      argument :helpdesk_ticket_id, :uuid
      argument :project_id, :uuid
      argument :partner_id, :uuid
      argument :user_id, :uuid
      validate present(:name)
      # message: "任务标题必填"
      # TODO: 不支持的 change effect callback
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :schedule do
      accept [:planned_date_begin, :planned_date_end]
      argument :user_id, :uuid
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
    update :complete do
      accept []
      change set_attribute(:is_done, true)
      # TODO: 不支持的 change effect callback
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
    identity :unique_field_service_name, [:name, :helpdesk_ticket_id]
  end

end
