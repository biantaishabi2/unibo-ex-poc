defmodule UniboV4.Sales.SalesOrderItemTaxRel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_order_item_tax_rels"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :order_item, UniboV4.Sales.SalesOrderItem do
      public? true
      allow_nil? false
      source_attribute :sales_order_item_id
    end
    belongs_to :tax, UniboV4.Sales.Tax do
      public? true
      allow_nil? false
    end
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
