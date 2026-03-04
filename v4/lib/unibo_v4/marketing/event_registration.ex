# Workflow: event_registration_lifecycle — 活动报名生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   create --> cancel
#   confirm --> set_done
#   confirm --> cancel
#   confirm --> send_badge_email
#   set_done --> [*]
#   cancel --> set_previous_state
#   set_previous_state --> confirm
#   send_badge_email --> [*]
# ```
defmodule UniboV4.Marketing.EventRegistration do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_event_registrations"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :attendee_name, :string do
      allow_nil? false
      public? true
    end
    attribute :attendee_email, :string, public?: true
    attribute :attendee_phone, :string, public?: true
    attribute :company_name, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :open, :done, :cancel]
      default :draft
      public? true
    end
    attribute :registration_date, :date do
      allow_nil? false
      public? true
    end
    attribute :date_closed, :utc_datetime, public?: true
    attribute :barcode, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Marketing.Event do
      public? true
      allow_nil? false
    end
    belongs_to :ticket, UniboV4.Marketing.EventTicket do
      public? true
    end
    belongs_to :partner, UniboV4.Marketing.Contact do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:attendee_name, :attendee_email, :attendee_phone, :company_name, :registration_date, :barcode]
      argument :event_id, :uuid, allow_nil?: false
      argument :ticket_id, :uuid
      argument :partner_id, :uuid
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:attendee_name)
      # TODO: 不支持的 action 内校验规则 custom
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
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :open)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
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
    update :set_done do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
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
      change set_attribute(:status, :cancel)
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
    update :set_previous_state do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:open, :done] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:open, :done]}))
        end
      end
      # message: "仅 open/done 状态允许回滚"
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
    action :register_attendee do
      argument :barcode, :string
      argument :event_id, :string
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
    action :send_badge_email do
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  identities do
    identity :unique_barcode, [:barcode]
  end

end
