# Workflow: utm_campaign_maintain_flow — UTM 活动维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.UtmCampaign do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "UTM 活动标识，用于归因营销活动效果"
  end

  postgres do
    table "marketing_utm_campaigns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_utm_campaign

    queries do
      get :get_marketing_utm_campaign, :read
      list :list_marketing_utm_campaigns, :read
    end

    mutations do
      create :create_marketing_utm_campaign, :create
      update :update_marketing_utm_campaign, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "活动唯一标识符（自动生成，去重后缀 [N]）"
    end
    attribute :title, :string do
      allow_nil? false
      public? true
      description "活动显示名称"
    end
    attribute :is_auto_campaign, :boolean do
      default false
      public? true
      description "是否由系统自动生成"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "颜色索引（看板展示用）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "归档标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :stage, UniboExPoc.Marketing.UtmStage do
      public? true
    end
    belongs_to :responsible, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :responsible_party_id
    end
    many_to_many :tags, UniboExPoc.Marketing.UtmTag do
      public? true
      through UniboExPoc.Marketing.UtmCampaignTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :title, :is_auto_campaign, :color, :active]
      argument :stage_id, :uuid
      argument :responsible_id, :uuid
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :title, :is_auto_campaign, :color, :active]
      argument :stage_id, :uuid
      argument :responsible_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_utm_campaign_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
