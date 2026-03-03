# Workflow: automation_trace_lifecycle — 自动化执行追踪
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> execute
#   create --> cancel
#   execute --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Marketing.AutomationTrace do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_automation_traces"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_automation_trace

    queries do
      get :get_marketing_automation_trace, :read
      list :list_marketing_automation_traces, :read
    end

    mutations do
      create :create_marketing_automation_trace, :create
      update :execute_marketing_automation_trace, :execute
      update :cancel_marketing_automation_trace, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:scheduled, :processed, :rejected, :canceled, :error]
      default :scheduled
      public? true
    end
    attribute :schedule_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_triggered, :utc_datetime, public?: true
    attribute :state_msg, :string, public?: true
    attribute :links_click_datetime, :utc_datetime, public?: true
    attribute :mail_open_datetime, :utc_datetime, public?: true
    attribute :system_triggered, :boolean do
      default true
      public? true
    end
    attribute :channel, :string, public?: true
    attribute :channel_id, :integer, public?: true
    attribute :metadata, :string, public?: true
    attribute :non_action_path_taken, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :activity, UniboV4.Marketing.AutomationActivity do
      public? true
      allow_nil? false
    end
    belongs_to :participant, UniboV4.Marketing.AutomationParticipant do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:schedule_date, :system_triggered]
      argument :activity_id, :uuid, allow_nil?: false
      argument :participant_id, :uuid, allow_nil?: false
      change manage_relationship(:activity_id, :activity, type: :append, on_lookup: :relate)
      change manage_relationship(:participant_id, :participant, type: :append, on_lookup: :relate)
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
    update :execute do
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :scheduled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :scheduled}))
        end
      end
      # message: "T-R1: 仅 scheduled 状态的 trace 可被执行"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:state, :processed)
      change set_attribute(:date_triggered, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect custom
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
    update :cancel do
      accept []
      change set_attribute(:state, :canceled)
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
    identity :unique_activity_participant, [:activity_id, :participant_id]
  end

end
