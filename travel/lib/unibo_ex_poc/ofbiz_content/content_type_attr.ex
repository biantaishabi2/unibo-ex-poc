defmodule UniboExPoc.Ofbiz.Content.ContentTypeAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_type_attr

    queries do
      get :get_content_content_type_attr, :read
      list :list_content_content_type_attrs, :read
    end

    mutations do
      create :create_content_content_type_attr, :create
      update :update_content_content_type_attr, :update
      destroy :delete_content_content_type_attr, :destroy
    end

  end

  attributes do
    attribute :content_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content_type, UniboExPoc.Ofbiz.Content.ContentType do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
