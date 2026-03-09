defmodule UniboExPoc.Ofbiz.Content.DocumentType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_document_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_document_type

    queries do
      get :get_content_document_type, :read
      list :list_content_document_types, :read
    end

    mutations do
      create :create_content_document_type, :create
      update :update_content_document_type, :update
      destroy :delete_content_document_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :document_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_document_type, UniboExPoc.Ofbiz.Content.DocumentType do
      public? true
      source_attribute :parent_type_id
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
