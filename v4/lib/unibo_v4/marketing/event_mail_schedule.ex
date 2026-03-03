# Workflow: event_mail_schedule_maintain_flow — 活动邮件计划维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Marketing.EventMailSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_event_mail_schedules"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_event_mail_schedule

    queries do
      get :get_marketing_event_mail_schedule, :read
      list :list_marketing_event_mail_schedules, :read
    end

    mutations do
      create :create_marketing_event_mail_schedule, :create
      update :update_marketing_event_mail_schedule, :update
      destroy :delete_marketing_event_mail_schedule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :interval_type, :atom do
      constraints one_of: [:after_sub, :before_event, :after_event]
      public? true
    end
    attribute :interval_nbr, :integer do
      default 0
      public? true
    end
    attribute :interval_unit, :atom do
      constraints one_of: [:now, :hours, :days, :weeks]
      default &DateTime.utc_now/0
      public? true
    end
    attribute :template_ref, :string, public?: true
    attribute :mail_done, :boolean do
      default false
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
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:interval_type, :interval_nbr, :interval_unit, :template_ref]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:interval_type)
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
      accept [:interval_type, :interval_nbr, :interval_unit, :template_ref]
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

end
