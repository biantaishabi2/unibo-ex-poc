defmodule UniboV4.Ecommerce.ProductVariant do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "product_variants"
    repo UniboV4.Repo
  end

  graphql do
    type :product_variant

    queries do
      get :get_product_variant, :read
      list :list_product_variants, :read
    end

    mutations do
      create :create_product_variant, :create
      update :update_product_variant, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sku, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :attributes_json, :string
    attribute :price, :decimal, allow_nil?: false
    attribute :stock_quantity, :integer, default: 0
    attribute :is_active, :boolean, default: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :template, UniboV4.Ecommerce.ProductTemplate do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:sku, :name, :attributes_json, :price, :stock_quantity]
      argument :template_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      validate present(:sku)
    end
    update :update do
      primary? true
      accept [:name, :attributes_json, :price, :stock_quantity, :is_active]
    end
  end

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_sku, [:sku]
  end

end
