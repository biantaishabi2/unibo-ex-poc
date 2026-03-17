defmodule UniboExPoc.Ofbiz.Party.UserLogin do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "party_user_logins"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
  end

end
