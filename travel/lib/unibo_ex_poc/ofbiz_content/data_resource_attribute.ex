defmodule UniboExPoc.Ofbiz.Content.DataResourceAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_data_resource_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_data_resource_attribute

    queries do
      get :get_content_data_resource_attribute, :read
      list :list_content_data_resource_attributes, :read
    end

    mutations do
      create :create_content_data_resource_attribute, :create
      update :update_content_data_resource_attribute, :update
      destroy :delete_content_data_resource_attribute, :destroy
    end

  end

  attributes do
    attribute :data_resource_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource, UniboExPoc.Ofbiz.Content.DataResource do
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
