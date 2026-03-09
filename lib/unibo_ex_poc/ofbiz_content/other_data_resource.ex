defmodule UniboExPoc.Ofbiz.Content.OtherDataResource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_other_data_resources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_other_data_resource

    queries do
      get :get_content_other_data_resource, :read
      list :list_content_other_data_resources, :read
    end

    mutations do
      create :create_content_other_data_resource, :create
      update :update_content_other_data_resource, :update
      destroy :delete_content_other_data_resource, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :data_resource_content, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource, UniboExPoc.Ofbiz.Content.DataResource do
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
