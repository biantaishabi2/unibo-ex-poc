defmodule UniboExPoc.Ofbiz.Shipment.RoleType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "shipment_role_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_role_type

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
  end

end
