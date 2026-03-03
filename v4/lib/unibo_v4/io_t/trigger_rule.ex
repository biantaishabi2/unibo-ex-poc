# Workflow: trigger_rule_toggle_flow — 触发规则创建、维护与启停流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   activate --> [*]
#   deactivate --> [*]
# ```
defmodule UniboV4.IoT.TriggerRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "io_t_trigger_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :io_t_trigger_rule

    queries do
      get :get_io_t_trigger_rule, :read
      list :list_io_t_trigger_rules, :read
    end

    mutations do
      create :create_io_t_trigger_rule, :create
      update :update_io_t_trigger_rule, :update
      update :activate_io_t_trigger_rule, :activate
      update :deactivate_io_t_trigger_rule, :deactivate
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:scan, :weight_stable, :button_press, :measurement, :temperature_alert]
      public? true
    end
    attribute :condition, :string, public?: true
    attribute :action_type, :atom do
      allow_nil? false
      constraints one_of: [:print_report, :create_record, :call_webhook, :update_field, :notify_user]
      public? true
    end
    attribute :action_config, :string do
      allow_nil? false
      public? true
    end
    attribute :is_active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :priority, :integer do
      default 10
      public? true
    end
    attribute :stop_on_match, :boolean do
      default false
      public? true
    end
    attribute :cooldown_seconds, :integer do
      default 5
      public? true
    end
    attribute :last_triggered_at, :utc_datetime, public?: true
    attribute :execution_count, :integer do
      default 0
      public? true
    end
    attribute :error_count, :integer do
      default 0
      public? true
    end
    attribute :error_action, :atom do
      constraints one_of: [:ignore, :retry_once, :notify_admin]
      default :notify_admin
      public? true
    end
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :success_rate
    # TODO: 不支持的 calculation 表达式 :is_in_cooldown
  end

  relationships do
    belongs_to :device, UniboV4.IoT.IoTDevice do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :event_logs, UniboV4.IoT.EventLog do
      public? true
      destination_attribute :trigger_rule_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :event_type, :condition, :action_type, :action_config, :is_active, :priority, :stop_on_match, :cooldown_seconds, :error_action]
      argument :device_id, :uuid, allow_nil?: false
      change manage_relationship(:device_id, :device, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:device_id)
      validate present(:action_config)
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
      accept [:name, :description, :condition, :action_type, :action_config, :is_active, :priority, :stop_on_match, :cooldown_seconds, :error_action]
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
    update :activate do
      accept []
      change set_attribute(:is_active, true)
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
    update :deactivate do
      accept []
      change set_attribute(:is_active, false)
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
