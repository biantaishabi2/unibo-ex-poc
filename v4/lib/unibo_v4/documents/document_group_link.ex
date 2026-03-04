defmodule UniboV4.Documents.DocumentGroupLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_document_group_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :document, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
    belongs_to :group, UniboV4.Documents.Group do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
