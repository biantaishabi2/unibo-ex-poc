defmodule UniboExPoc.Ofbiz.Shipment.Product do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "shipment_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_product

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
  end

end
