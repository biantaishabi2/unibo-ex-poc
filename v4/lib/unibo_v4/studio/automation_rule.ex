# Workflow: automation_rule_lifecycle — 自动化规则生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> execute
#   create --> destroy
#   update --> execute
#   update --> destroy
#   execute --> update
#   execute --> execute
#   destroy --> [*]
# ```
defmodule UniboV4.Studio.AutomationRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "studio_automation_rules"
    repo UniboV4.Repo
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
    attribute :trigger_type, :atom do
      allow_nil? false
      constraints one_of: [:on_create, :on_write, :on_create_or_write, :on_delete, :on_time, :on_condition, :on_webhook, :manual]
      public? true
    end
    attribute :trigger_config, :string do
      allow_nil? false
      public? true
    end
    attribute :condition_domain, :string, public?: true
    attribute :action_type, :atom do
      allow_nil? false
      constraints one_of: [:update_record, :create_record, :send_email, :send_notification, :execute_code, :call_webhook, :add_followers, :chain_automation]
      public? true
    end
    attribute :action_config, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer, public?: true
    attribute :is_active, :boolean do
      default false
      public? true
    end
    attribute :last_run_at, :utc_datetime, public?: true
    attribute :run_count, :integer do
      default 0
      public? true
    end
    attribute :error_count, :integer do
      default 0
      public? true
    end
    attribute :last_error, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :model, UniboV4.Studio.CustomModel do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :trigger_type, :trigger_config, :condition_domain, :action_type, :action_config, :sequence, :is_active]
      argument :model_id, :integer, allow_nil?: false
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:trigger_type)
      validate present(:action_type)
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
      accept [:name, :trigger_type, :trigger_config, :condition_domain, :action_type, :action_config, :sequence, :is_active]
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
    update :execute do
      accept []
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
