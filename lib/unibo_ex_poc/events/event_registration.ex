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
defmodule UniboExPoc.Events.EventRegistration do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Events.EventRegistration.Notifier]

  resource do
    description "活动报名记录，管理参与者的报名、确认、签到全流程"
  end

  postgres do
    table "events_event_registrations"
    repo UniboExPoc.Repo
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
      description "参与角色（对应 role_type_id）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :confirmed, :cancelled, :attended]
      default :pending
      public? true
      description "报名状态（对应 status_id）"
    end
    attribute :registered_at, :utc_datetime do
      allow_nil? false
      public? true
      description "报名时间（对应 from_date）"
    end
    attribute :status_changed_at, :utc_datetime do
      public? true
      description "状态变更时间（对应 status_date_time）"
    end
    attribute :check_in_time, :utc_datetime do
      public? true
      description "签到时间"
    end
    attribute :payment_status, :atom do
      constraints one_of: [:unpaid, :paid, :refunded]
      default :unpaid
      public? true
      description "付款状态"
    end
    attribute :comments, :string do
      public? true
      description "报名备注/留言"
    end
    attribute :must_rsvp, :boolean do
      default false
      public? true
      description "是否需要确认 RSVP"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboExPoc.Events.Event do
      public? true
      allow_nil? false
    end
    belongs_to :attendee, UniboExPoc.Events.Party do
      public? true
      allow_nil? false
      source_attribute :attendee_party_id
    end
    belongs_to :ticket, UniboExPoc.Events.EventTicket do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :register do
      description "报名参加活动"
      primary? true
      accept [:event_id, :role, :ticket_id, :comments, :must_rsvp]
      argument :attendee_id, :uuid
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      argument :attendee_id, :uuid, allow_nil?: false
      change manage_relationship(:attendee_id, :attendee, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:attendee_id)
      # validation: capacity_check — 活动名额已满，无法报名
      change UniboExPoc.Events.Changes.EventRegistration.ComputeRegisteredAt
      change set_attribute(:id, expr(id))
    end
    update :confirm do
      description "确认报名（pending -> confirmed）"
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
      change UniboExPoc.Events.Changes.EventRegistration.ComputeStatusChangedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :check_in do
      description "现场签到（confirmed -> attended）"
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
      change UniboExPoc.Events.Changes.EventRegistration.ComputeCheckInTime
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消报名（pending/confirmed -> cancelled）"
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
      change UniboExPoc.Events.Changes.EventRegistration.ComputeStatusChangedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_event_attendee, [:event_id, :attendee_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
