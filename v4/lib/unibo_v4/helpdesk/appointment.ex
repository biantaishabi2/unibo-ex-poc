# Workflow: appointment_lifecycle — 预约生命周期（排期→确认→完成/取消）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   create --> cancel
#   confirm --> complete
#   confirm --> cancel
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Helpdesk.Appointment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_appointments"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_appointment

    queries do
      get :get_helpdesk_appointment, :read
      list :list_helpdesk_appointments, :read
    end

    mutations do
      create :create_helpdesk_appointment, :create
      update :confirm_helpdesk_appointment, :confirm
      update :complete_helpdesk_appointment, :complete
      update :cancel_helpdesk_appointment, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:scheduled, :confirmed, :completed, :cancelled, :no_show]
      default :scheduled
      public? true
    end
    attribute :start_time, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :end_time, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :location, :string, public?: true
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboV4.Helpdesk.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :start_time, :end_time, :location, :description, :notes]
      validate present(:title)
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
    update :confirm do
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :scheduled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :scheduled}))
        end
      end
      # message: "只有已排期状态可以确认"
      change set_attribute(:status, :confirmed)
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以完成"
      change set_attribute(:status, :completed)
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
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:scheduled, :confirmed] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:scheduled, :confirmed]}))
        end
      end
      # message: "只有排期或已确认状态可以取消"
      change set_attribute(:status, :cancelled)
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
