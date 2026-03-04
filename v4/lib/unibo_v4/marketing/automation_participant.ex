# Workflow: automation_participant_creation_flow — 自动化参与者创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Marketing.AutomationParticipant do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_automation_participants"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :record_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:running, :completed, :unlinked, :error]
      default :running
      public? true
    end
    attribute :is_test, :boolean do
      default false
      public? true
    end
    attribute :rotation, :integer do
      default 1
      public? true
    end
    attribute :points, :integer do
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
    belongs_to :partner, UniboV4.Marketing.Contact do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:record_id, :model_id, :is_test]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect custom
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

  identities do
    identity :unique_campaign_record_rotation, [:campaign_id, :record_id, :rotation]
  end

end
