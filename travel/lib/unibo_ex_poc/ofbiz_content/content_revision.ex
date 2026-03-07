defmodule UniboExPoc.Ofbiz.Content.ContentRevision do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_revisions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_revision

    queries do
      get :get_content_content_revision, :read
      list :list_content_content_revisions, :read
    end

    mutations do
      create :create_content_content_revision, :create
      update :update_content_content_revision, :update
      destroy :delete_content_content_revision, :destroy
    end

  end

  attributes do
    attribute :content_revision_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :committed_by_party_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
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
