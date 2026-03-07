defmodule UniboExPoc.Ofbiz.Party.SecurityGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "party_security_groups"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
  end

end
