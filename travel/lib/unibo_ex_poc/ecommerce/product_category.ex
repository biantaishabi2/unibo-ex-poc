# Workflow: category_lifecycle — 产品分类管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Ecommerce.ProductCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "产品分类"
  end

  postgres do
    table "ecommerce_product_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_product_category

    queries do
      get :get_ecommerce_product_category, :read
      list :list_ecommerce_product_categorys, :read
    end

    mutations do
      create :create_ecommerce_product_category, :create
      update :update_ecommerce_product_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :category_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, UniboExPoc.Ecommerce.ProductCategory do
      public? true
    end
    has_many :products, UniboExPoc.Ecommerce.ProductTemplate do
      public? true
      source_attribute :parent_id
      destination_attribute :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:category_code, :name, :description]
      argument :parent_id, :uuid
      validate present(:category_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_category_code, [:category_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
