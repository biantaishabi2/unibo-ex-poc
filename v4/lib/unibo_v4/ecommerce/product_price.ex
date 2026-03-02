defmodule UniboV4.Ecommerce.ProductPrice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "product_prices"
    repo UniboV4.Repo
  end

  graphql do
    type :product_price

    queries do
      get :get_product_price, :read
      list :list_product_prices, :read
    end

    mutations do
      create :create_product_price, :create
      update :update_product_price, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :price_type, :atom do
      allow_nil? false
      constraints one_of: [:list_price, :sale_price, :cost_price, :member_price]
        public? true
    end
    attribute :amount, :decimal, allow_nil?: false, public?: true
    attribute :currency, :string, default: "CNY", public?: true
    attribute :from_date, :date, allow_nil?: false, public?: true
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :product, UniboV4.Ecommerce.ProductTemplate do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:price_type, :amount, :currency, :from_date, :thru_date]
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:amount, :thru_date]
    end
  end

  validations do
    validate compare(:amount, greater_than_or_equal_to: 0)
  end

end
