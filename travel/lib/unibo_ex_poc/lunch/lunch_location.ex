# Workflow: location_management — 配送地点管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Lunch.LunchLocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "午餐配送地点"
  end

  postgres do
    table "lunch_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_location

    queries do
      get :get_lunch_lunch_location, :read
      list :list_lunch_lunch_locations, :read
    end

    mutations do
      create :create_lunch_lunch_location, :create
      update :update_lunch_lunch_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "地点名称"
    end
    attribute :address, :string do
      public? true
      description "地址"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :address]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :address]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
