defmodule UniboV4.Ofbiz.Content.Document do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_documents"
    repo UniboV4.Repo
  end

  graphql do
    type :content_document

    queries do
      get :get_content_document, :read
      list :list_content_documents, :read
    end

    mutations do
      create :create_content_document, :create
      update :update_content_document, :update
      destroy :delete_content_document, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :document_id, :string, public?: true
    attribute :date_created, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :document_location, :string, public?: true
    attribute :document_text, :string, public?: true
    attribute :image_data, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :document_type, UniboV4.Ofbiz.Content.DocumentType do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
