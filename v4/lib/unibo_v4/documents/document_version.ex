defmodule UniboV4.Documents.DocumentVersion do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_document_versions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :attachment_id, :uuid, public?: true
  end

  relationships do
    belongs_to :document, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
