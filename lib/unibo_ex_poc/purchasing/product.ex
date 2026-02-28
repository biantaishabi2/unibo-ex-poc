defmodule UniboExPoc.Purchasing.Product do
  @moduledoc """
  产品 — 对应 OFBiz Product。
  精简为采购场景所需的核心字段。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:product)

    queries do
      get(:get_product, :read)
      list(:list_products, :read)
    end

    mutations do
      create :create_product, :create
      update(:update_product, :update)
    end
  end

  postgres do
    table("products")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    # 对应 OFBiz Product.productTypeId
    attribute :product_type, :atom do
      constraints(one_of: [:finished_good, :raw_material, :service, :digital_good])
      default(:finished_good)
      public?(true)
    end

    # 对应 OFBiz Product.internalName
    attribute :internal_name, :string do
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz Product.productName
    attribute :product_name, :string do
      public?(true)
    end

    # 对应 OFBiz Product.description
    attribute :description, :string do
      public?(true)
    end

    # 对应 OFBiz Product.quantityUomId — 计量单位
    attribute :uom, :string do
      default("EA")
      public?(true)
    end

    # 对应 OFBiz ProductPrice.price — 简化为单一标准价格
    attribute :standard_price, :decimal do
      public?(true)
    end

    # 对应 OFBiz ProductPrice.currencyUomId
    attribute :currency, :string do
      default("CNY")
      public?(true)
    end

    # 对应 OFBiz Product.taxable
    attribute :taxable, :boolean do
      default(true)
      public?(true)
    end

    # 对应 OFBiz Product.returnable
    attribute :returnable, :boolean do
      default(true)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([
        :product_type,
        :internal_name,
        :product_name,
        :description,
        :uom,
        :standard_price,
        :currency,
        :taxable,
        :returnable
      ])
    end

    update :update do
      accept([:product_name, :description, :standard_price, :currency, :taxable, :returnable])
    end
  end

  identities do
    identity(:internal_name, [:internal_name], pre_check?: true)
  end
end
