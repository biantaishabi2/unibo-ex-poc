defmodule UniboV4.Ecommerce.ShoppingCart do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "shopping_carts"
    repo UniboV4.Repo
  end

  graphql do
    type :shopping_cart

    queries do
      get :get_shopping_cart, :read
      list :list_shopping_carts, :read
    end

    mutations do
      create :create_shopping_cart, :create
      update :update_shopping_cart, :update
      update :convert_shopping_cart, :convert
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:active, :converted, :abandoned]
      default :active
        public? true
    end
    attribute :total_amount, :decimal, default: 0, public?: true
    attribute :item_count, :integer, default: 0, public?: true
    attribute :currency, :string, default: "CNY", public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, UniboV4.Accounts.User, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:currency]
      change relate_actor(:owner)
    end
    update :update do
      primary? true
      accept [:total_amount, :item_count, :status]
    end
    update :convert do
      accept []
      validate attribute_equals(:status, :active) do
        message "只有活跃购物车可以转为订单"
      end
      change set_attribute(:status, :converted)
    end
  end

end
