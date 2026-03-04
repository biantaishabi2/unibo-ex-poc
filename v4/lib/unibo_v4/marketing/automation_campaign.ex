# Workflow: automation_campaign_lifecycle — 自动化活动生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> start_campaign
#   update --> start_campaign
#   start_campaign --> stop_campaign
#   stop_campaign --> [*]
# ```
defmodule UniboV4.Marketing.AutomationCampaign do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Marketing.AutomationCampaign.Notifier]

  postgres do
    table "marketing_automation_campaigns"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :running, :stopped, :done]
      default :draft
      public? true
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :domain_filter, :string, public?: true
    attribute :unique_field_id, :uuid, public?: true
    attribute :allow_restart, :boolean do
      default false
      public? true
    end
    attribute :category_id, :uuid, public?: true
    attribute :canvas_settings, :string, public?: true
    attribute :sync_last_date, :utc_datetime, public?: true
    attribute :fixed_cost, :decimal, public?: true
    attribute :publish_up, :utc_datetime, public?: true
    attribute :publish_down, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :activities, UniboV4.Marketing.AutomationActivity do
      public? true
      destination_attribute :campaign_id
    end
    has_many :participants, UniboV4.Marketing.AutomationParticipant do
      public? true
      destination_attribute :campaign_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :model_id, :domain_filter, :unique_field_id, :allow_restart, :category_id, :fixed_cost, :publish_up, :publish_down]
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
      accept [:name, :domain_filter, :unique_field_id, :allow_restart, :category_id, :canvas_settings, :fixed_cost, :publish_up, :publish_down]
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
    update :start_campaign do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :stopped] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :stopped]}))
        end
      end
      # message: "只有草稿或已停止状态可以启动"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:state, :running)
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
    update :stop_campaign do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以停止"
      change set_attribute(:state, :stopped)
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
