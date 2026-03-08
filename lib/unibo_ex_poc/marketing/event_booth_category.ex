# Workflow: event_booth_category_maintain_flow — 展位类别维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.EventBoothCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "展位分类（如标准展位、豪华展位等）"
  end

  postgres do
    table "marketing_event_booth_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_event_booth_category

    queries do
      get :get_marketing_event_booth_category, :read
      list :list_marketing_event_booth_categorys, :read
    end

    mutations do
      create :create_marketing_event_booth_category, :create
      update :update_marketing_event_booth_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "分类名称"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序序号"
    end
    attribute :description, :string do
      public? true
      description "分类描述（富文本）"
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
    has_many :booths, UniboV4.Marketing.EventBooth do
      public? true
      destination_attribute :booth_category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :description, :active]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :description, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_booth_category_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
