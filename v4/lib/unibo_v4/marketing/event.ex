# Workflow: event_lifecycle — 活动/展会生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> publish
#   publish --> complete
#   publish --> cancel
#   publish --> set_done
#   complete --> [*]
#   cancel --> [*]
#   set_done --> [*]
# ```
defmodule UniboV4.Marketing.Event do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_events"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :event_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :published, :ongoing, :completed, :cancelled]
      default :draft
      public? true
    end
    attribute :stage_id, :uuid, public?: true
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
    end
    attribute :event_type_id, :uuid, public?: true
    attribute :start_date, :utc_datetime, public?: true
    attribute :end_date, :utc_datetime, public?: true
    attribute :date_tz, :string, public?: true
    attribute :location, :string, public?: true
    attribute :seats_max, :integer do
      default 0
      public? true
    end
    attribute :seats_limited, :boolean do
      default false
      public? true
    end
    attribute :auto_confirm, :boolean do
      default false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :registrations, UniboV4.Marketing.EventRegistration do
      public? true
    end
    has_many :tickets, UniboV4.Marketing.EventTicket do
      public? true
    end
    has_many :event_mails, UniboV4.Marketing.EventMailSchedule do
      public? true
    end
    has_many :booths, UniboV4.Marketing.EventBooth do
      public? true
      destination_attribute :event_id
    end
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:event_code, :name, :start_date, :end_date, :date_tz, :location, :seats_max, :seats_limited, :auto_confirm, :description, :event_type_id]
      argument :campaign_id, :uuid
      validate present(:event_code)
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
      accept [:name, :start_date, :end_date, :date_tz, :location, :seats_max, :seats_limited, :auto_confirm, :description, :stage_id, :event_type_id]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:kanban_state, :normal)
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
    update :publish do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :published)
      change set_attribute(:kanban_state, :normal)
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
    update :complete do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:published, :ongoing] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:published, :ongoing]}))
        end
      end
      # message: "只有已发布或进行中状态可以完成"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :completed)
      change set_attribute(:kanban_state, :normal)
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
    update :cancel do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancelled)
      change set_attribute(:kanban_state, :normal)
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :completed)
      change set_attribute(:kanban_state, :normal)
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
  end

  identities do
    identity :unique_event_code, [:event_code]
  end

end
