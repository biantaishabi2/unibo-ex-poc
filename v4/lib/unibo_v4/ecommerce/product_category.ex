defmodule UniboV4.Ecommerce.ProductCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "product_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :product_category

    queries do
      get :get_product_category, :read
      list :list_product_categorys, :read
    end

    mutations do
      create :create_product_category, :create
      update :update_product_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :category_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, UniboV4.Ecommerce.ProductCategory, public?: true
    has_many :products, UniboV4.Ecommerce.ProductTemplate
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:category_code, :name, :description]
      argument :parent_id, :uuid
      validate present(:category_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
  end

  identities do
    identity :unique_category_code, [:category_code]
  end

end
