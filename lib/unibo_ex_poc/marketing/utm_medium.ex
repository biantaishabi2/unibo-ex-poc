# Workflow: utm_medium_maintain_flow — UTM 媒介维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.UtmMedium do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "UTM 媒介渠道（如 email、social、cpc 等）"
  end

  postgres do
    table "marketing_utm_mediums"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_utm_medium

    queries do
      get :get_marketing_utm_medium, :read
      list :list_marketing_utm_mediums, :read
    end

    mutations do
      create :create_marketing_utm_medium, :create
      update :update_marketing_utm_medium, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "媒介名称"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "归档标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :active]
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_utm_medium_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
