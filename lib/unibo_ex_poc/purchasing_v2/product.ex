defmodule UniboExPoc.PurchasingV2.Product do
  @moduledoc """
  V2 产品资源：提供订单行项关联的最小产品模型。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV2,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:product_v2)

    queries do
      get(:get_product_v2, :read)
      list(:list_products_v2, :read)
    end

    mutations do
      create :create_product_v2, :create
      update(:update_product_v2, :update)
    end
  end

  postgres do
    table("v2_products")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :internal_name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :product_name, :string do
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:internal_name, :product_name])
    end

    update :update do
      accept([:product_name])
    end
  end

  identities do
    identity(:internal_name, [:internal_name], pre_check?: true)
  end
end
