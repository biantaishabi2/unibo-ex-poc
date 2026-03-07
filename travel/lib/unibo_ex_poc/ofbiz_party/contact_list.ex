defmodule UniboExPoc.Ofbiz.Party.ContactList do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "party_contact_lists"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
  end

end
