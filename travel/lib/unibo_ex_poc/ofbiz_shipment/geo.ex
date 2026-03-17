defmodule UniboExPoc.Ofbiz.Shipment.Geo do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "shipment_geos"
    repo UniboExPoc.Repo
  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
  end

end
