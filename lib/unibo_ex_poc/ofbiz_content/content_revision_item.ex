defmodule UniboV4.Ofbiz.Content.ContentRevisionItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_revision_items"
    repo UniboV4.Repo
  end

  graphql do
    type :content_content_revision_item

    queries do
      get :get_content_content_revision_item, :read
      list :list_content_content_revision_items, :read
    end

    mutations do
      create :create_content_content_revision_item, :create
      update :update_content_content_revision_item, :update
      destroy :delete_content_content_revision_item, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :content_revision_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :item_content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :old_data_resource, UniboV4.Ofbiz.Content.DataResource do
      public? true
      attribute_type :string
    end
    belongs_to :new_data_resource, UniboV4.Ofbiz.Content.DataResource do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
