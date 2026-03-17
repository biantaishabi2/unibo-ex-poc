defmodule UniboExPoc.Ofbiz.Party.StatusItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "party_status_items"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
  end

end
