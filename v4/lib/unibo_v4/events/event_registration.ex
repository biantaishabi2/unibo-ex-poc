# Workflow: registration_lifecycle — 报名完整生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> register
#   register --> confirm
#   register --> cancel
#   confirm --> check_in
#   confirm --> cancel
#   check_in --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Events.Events.EventRegistration do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Events.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Events.Events.EventRegistration.Notifier]

  postgres do
    table "events_event_registrations"
    repo UniboV4.Repo
  end

  graphql do
    type :events_event_registration

    queries do
      get :get_events_event_registration, :read
      list :list_events_event_registrations, :read
    end

    mutations do
      create :create_register_events_event_registration, :register
      update :confirm_events_event_registration, :confirm
      update :check_in_events_event_registration, :check_in
      update :cancel_events_event_registration, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:attendee, :speaker, :organizer]
      default :attendee
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :confirmed, :cancelled, :attended]
      default :pending
      public? true
    end
    attribute :registered_at, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :status_changed_at, :utc_datetime, public?: true
    attribute :check_in_time, :utc_datetime, public?: true
    attribute :payment_status, :atom do
      constraints one_of: [:unpaid, :paid, :refunded]
      default :unpaid
      public? true
    end
    attribute :comments, :string, public?: true
    attribute :must_rsvp, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Events.Events.Event do
      public? true
      allow_nil? false
    end
    belongs_to :attendee, UniboV4.Events.Events.User do
      public? true
      allow_nil? false
    end
    belongs_to :ticket, UniboV4.Events.Events.EventTicket do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :register do
      primary? true
      accept [:role, :comments, :must_rsvp]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      argument :attendee_id, :uuid, allow_nil?: false
      change manage_relationship(:attendee_id, :attendee, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:attendee_id)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 跨实体聚合表达式暂不支持
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
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待确认状态可以确认"
      change set_attribute(:status, :confirmed)
      # TODO: 跨实体聚合表达式暂不支持
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
    update :check_in do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以签到"
      change set_attribute(:status, :attended)
      # TODO: 跨实体聚合表达式暂不支持
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
        if current in [:pending, :confirmed] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:pending, :confirmed]}))
        end
      end
      # message: "只有待确认或已确认状态可以取消"
      change set_attribute(:status, :cancelled)
      # TODO: 跨实体聚合表达式暂不支持
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
    identity :unique_event_attendee, [:event_id, :attendee_id]
  end

end
