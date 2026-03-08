# Workflow: automation_participant_creation_flow — 自动化参与者创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Marketing.AutomationParticipant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "自动化活动参与者"
  end

  postgres do
    table "marketing_automation_participants"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_automation_participant

    queries do
      get :get_marketing_automation_participant, :read
      list :list_marketing_automation_participants, :read
    end

    mutations do
      create :create_marketing_automation_participant, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :record_id, :integer do
      allow_nil? false
      public? true
      description "目标模型中的记录 ID"
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
      description "目标模型引用"
    end
    attribute :state, :atom do
      constraints one_of: [:running, :completed, :unlinked, :error]
      default :running
      public? true
    end
    attribute :is_test, :boolean do
      default false
      public? true
      description "是否测试参与者"
    end
    attribute :rotation, :integer do
      default 1
      public? true
      description "参与轮次（allow_restart 时递增）"
    end
    attribute :points, :integer do
      default 0
      public? true
      description "此活动中的积分"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboExPoc.Marketing.AutomationCampaign do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Marketing.Contact do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:record_id, :model_id, :is_test]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      # validation: check_do_not_contact
      # validation: frequency_limit
      change UniboExPoc.Marketing.Changes.AutomationParticipant.CreateCall1
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_campaign_record_rotation, [:campaign_id, :record_id, :rotation]
  end

end
