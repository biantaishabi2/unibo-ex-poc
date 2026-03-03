defmodule UniboV4.Documents.FolderWriteGroupLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_folder_write_group_links"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_folder_write_group_link

    queries do
      get :get_documents_folder_write_group_link, :read
      list :list_documents_folder_write_group_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Folder do
      public? true
      allow_nil? false
    end
    belongs_to :group, UniboV4.Documents.Group do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
