defmodule UniboExPoc.Ofbiz.Content.DataResourcePurpose do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_data_resource_purposes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_data_resource_purpose

    queries do
      get :get_content_data_resource_purpose, :read
      list :list_content_data_resource_purposes, :read
    end

    mutations do
      create :create_content_data_resource_purpose, :create
      update :update_content_data_resource_purpose, :update
      destroy :delete_content_data_resource_purpose, :destroy
    end

  end

  attributes do
    attribute :data_resource_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :content_purpose_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource, UniboExPoc.Ofbiz.Content.DataResource do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :content_purpose_type, UniboExPoc.Ofbiz.Content.ContentPurposeType do
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
