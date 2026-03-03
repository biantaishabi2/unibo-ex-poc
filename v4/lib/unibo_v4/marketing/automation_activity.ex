# Workflow: automation_activity_maintain_flow — 自动化活动节点维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Marketing.AutomationActivity do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_automation_activities"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_automation_activity

    queries do
      get :get_marketing_automation_activity, :read
      list :list_marketing_automation_activitys, :read
    end

    mutations do
      create :create_marketing_automation_activity, :create
      update :update_marketing_automation_activity, :update
      destroy :delete_marketing_automation_activity, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :activity_type, :atom do
      allow_nil? false
      constraints one_of: [:email, :sms, :server_action, :whatsapp]
      public? true
    end
    attribute :trigger_type, :atom do
      allow_nil? false
      constraints one_of: [:begin, :activity_done, :mail_open, :mail_click, :mail_reply, :mail_not_open, :mail_bounce, :form_submit, :page_visit, :point_change, :stage_change]
      public? true
    end
    attribute :decision_path, :atom do
      constraints one_of: [:yes, :no]
      public? true
    end
    attribute :trigger_interval, :integer do
      default 0
      public? true
    end
    attribute :trigger_interval_type, :atom do
      constraints one_of: [:hours, :days, :weeks, :months]
      default :hours
      public? true
    end
    attribute :trigger_mode, :atom do
      constraints one_of: [:immediate, :interval, :date, :optimized]
      default :interval
      public? true
    end
    attribute :trigger_hour, :string, public?: true
    attribute :trigger_restricted_days, {:array, :string}, public?: true
    attribute :domain_filter, :string, public?: true
    attribute :condition, :string, public?: true
    attribute :server_action_id, :uuid, public?: true
    attribute :email_template_id, :uuid, public?: true
    attribute :sms_template_id, :uuid, public?: true
    attribute :variable_cost, :decimal, public?: true
    attribute :expiry_duration, :integer, public?: true
    attribute :expiry_duration_type, :atom do
      constraints one_of: [:hours, :days]
      public? true
    end
    attribute :order, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.AutomationCampaign do
      public? true
      allow_nil? false
    end
    belongs_to :parent, UniboV4.Marketing.AutomationActivity do
      public? true
    end
    has_many :children, UniboV4.Marketing.AutomationActivity do
      public? true
      destination_attribute :parent_id
    end
    has_many :traces, UniboV4.Marketing.AutomationTrace do
      public? true
      destination_attribute :activity_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :activity_type, :trigger_type, :decision_path, :trigger_interval, :trigger_interval_type, :trigger_mode, :trigger_hour, :trigger_restricted_days, :domain_filter, :condition, :server_action_id, :email_template_id, :sms_template_id, :variable_cost, :expiry_duration, :expiry_duration_type, :order]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :parent_id, :uuid
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
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
    update :update do
      primary? true
      accept [:name, :activity_type, :trigger_type, :decision_path, :trigger_interval, :trigger_interval_type, :trigger_mode, :trigger_hour, :trigger_restricted_days, :domain_filter, :condition, :server_action_id, :email_template_id, :sms_template_id, :variable_cost, :expiry_duration, :expiry_duration_type, :order]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
