# Workflow: event_lifecycle — 活动完整生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   create --> destroy
#   publish --> update
#   publish --> start
#   publish --> cancel
#   start --> complete
#   start --> cancel
#   complete --> archive
#   cancel --> archive
#   cancel --> destroy
#   archive --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Events.Event do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Events.Event.Notifier]

  postgres do
    table "events_events"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :published, :ongoing, :completed, :cancelled, :archived]
      default :draft
      public? true
    end
    attribute :start_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :end_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_end_date, :utc_datetime, public?: true
    attribute :location, :string, public?: true
    attribute :venue_id, :uuid, public?: true
    attribute :capacity, :integer, public?: true
    attribute :registration_deadline, :utc_datetime, public?: true
    attribute :is_online, :boolean do
      default false
      public? true
    end
    attribute :cover_image_url, :string, public?: true
    attribute :detail_url, :string, public?: true
    attribute :streaming_url, :string, public?: true
    attribute :priority, :integer do
      default 0
      public? true
    end
    attribute :send_notification_email, :boolean do
      default true
      public? true
    end
    attribute :total_budget, :decimal, public?: true
    attribute :budget_currency_id, :string, public?: true
    attribute :special_terms, :string, public?: true
    attribute :organizer_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event_type, UniboV4.Events.EventType do
      public? true
      allow_nil? false
    end
    has_many :registrations, UniboV4.Events.EventRegistration do
      public? true
      destination_attribute :event_id
    end
    has_many :tickets, UniboV4.Events.EventTicket do
      public? true
      destination_attribute :event_id
    end
    has_many :booths, UniboV4.Events.EventBooth do
      public? true
      destination_attribute :event_id
    end
    has_many :stages, UniboV4.Events.EventStage do
      public? true
      destination_attribute :event_id
    end
    belongs_to :parent_event, UniboV4.Events.Event do
      public? true
    end
    has_many :sub_events, UniboV4.Events.Event do
      public? true
      destination_attribute :parent_event_id
    end
    has_many :translations, UniboV4.Events.EventTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :start_date, :end_date, :location, :venue_id, :capacity, :registration_deadline, :is_online, :cover_image_url, :detail_url, :streaming_url, :priority, :send_notification_email, :total_budget, :budget_currency_id, :special_terms, :organizer_id]
      argument :event_type_id, :uuid, allow_nil?: false
      change manage_relationship(:event_type_id, :event_type, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:start_date)
      validate present(:end_date)
      validate present(:event_type_id)
      # TODO: compare :end_date 参数无法识别
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
      accept [:name, :description, :start_date, :end_date, :location, :venue_id, :capacity, :registration_deadline, :is_online, :cover_image_url, :detail_url, :streaming_url, :priority, :send_notification_email, :total_budget, :budget_currency_id, :special_terms, :organizer_id]
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
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
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态的活动可以发布"
      change set_attribute(:status, :published)
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
    update :start do
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :published do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :published}))
        end
      end
      # message: "只有已发布状态的活动可以开始"
      change set_attribute(:status, :ongoing)
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
    update :complete do
      accept []
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :ongoing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :ongoing}))
        end
      end
      # message: "只有进行中状态的活动可以完成"
      change set_attribute(:status, :completed)
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
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:published, :ongoing] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:published, :ongoing]}))
        end
      end
      # message: "只有已发布或进行中的活动可以取消"
      change set_attribute(:status, :cancelled)
      # TODO: 不支持的 change effect notify_registrants
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
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:completed, :cancelled] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:completed, :cancelled]}))
        end
      end
      # message: "只有已完成或已取消的活动可以归档"
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
    destroy :destroy do
      validate attribute_in(:status, [:draft, :cancelled])
      # message: "只有草稿或已取消状态的活动可以删除"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
