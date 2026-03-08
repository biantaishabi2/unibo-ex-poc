# Workflow: utm_stage_maintain_flow — UTM 阶段维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.UtmStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "UTM 活动阶段（看板列）"
  end

  postgres do
    table "marketing_utm_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_utm_stage

    queries do
      get :get_marketing_utm_stage, :read
      list :list_marketing_utm_stages, :read
    end

    mutations do
      create :create_marketing_utm_stage, :create
      update :update_marketing_utm_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段名称"
    end
    attribute :sequence, :integer do
      default 1
      public? true
      description "排序序号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :campaigns, UniboExPoc.Marketing.UtmCampaign do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_utm_stage_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
