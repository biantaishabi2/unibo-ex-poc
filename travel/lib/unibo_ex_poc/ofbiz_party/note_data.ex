defmodule UniboExPoc.Ofbiz.Party.NoteData do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "party_note_datas"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_note_data

  end

  attributes do
    uuid_primary_key :id
  end

end
