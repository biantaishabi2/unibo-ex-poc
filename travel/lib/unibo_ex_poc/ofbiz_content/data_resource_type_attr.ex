defmodule UniboExPoc.Ofbiz.Content.DataResourceTypeAttr do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_data_resource_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_data_resource_type_attr

    queries do
      get :get_content_data_resource_type_attr, :read
      list :list_content_data_resource_type_attrs, :read
    end

    mutations do
      create :create_content_data_resource_type_attr, :create
      update :update_content_data_resource_type_attr, :update
      destroy :delete_content_data_resource_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource_type, UniboExPoc.Ofbiz.Content.DataResourceType do
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
