defmodule UniboV4.Ofbiz.Content.DataResourceMetaData do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_data_resource_meta_datas"
    repo UniboV4.Repo
  end

  graphql do
    type :content_data_resource_meta_data

    queries do
      get :get_content_data_resource_meta_data, :read
      list :list_content_data_resource_meta_datas, :read
    end

    mutations do
      create :create_content_data_resource_meta_data, :create
      update :update_content_data_resource_meta_data, :update
      destroy :delete_content_data_resource_meta_data, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :meta_data_value, :string, public?: true
    attribute :data_source_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource, UniboV4.Ofbiz.Content.DataResource do
      public? true
      attribute_type :string
    end
    belongs_to :meta_data_predicate, UniboV4.Ofbiz.Content.MetaDataPredicate do
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
