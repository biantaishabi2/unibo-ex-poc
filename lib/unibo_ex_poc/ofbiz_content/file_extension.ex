defmodule UniboV4.Ofbiz.Content.FileExtension do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_file_extensions"
    repo UniboV4.Repo
  end

  graphql do
    type :content_file_extension

    queries do
      get :get_content_file_extension, :read
      list :list_content_file_extensions, :read
    end

    mutations do
      create :create_content_file_extension, :create
      update :update_content_file_extension, :update
      destroy :delete_content_file_extension, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :file_extension_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :mime_type, UniboV4.Ofbiz.Content.MimeType do
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
