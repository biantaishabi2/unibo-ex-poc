defmodule UniboV4.Sales.Product do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_products"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read]
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
  end

end
