# Workflow: utm_tag_maintain_flow — UTM 标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.UtmTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "UTM 标签，用于活动分类"
  end

  postgres do
    table "marketing_utm_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_utm_tag

    queries do
      get :get_marketing_utm_tag, :read
      list :list_marketing_utm_tags, :read
    end

    mutations do
      create :create_marketing_utm_tag, :create
      update :update_marketing_utm_tag, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "颜色索引"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :campaigns, UniboV4.Marketing.UtmCampaign do
      public? true
      through UniboV4.Marketing.UtmCampaignTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :color]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :color]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_utm_tag_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
