defmodule UniboExPoc.Ofbiz.Common.DataSourceType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Data Source Type"
  end

  postgres do
    table "common_data_source_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_common_data_source_type

    queries do
      get :get_ofbiz_common_data_source_type, :read
      list :list_ofbiz_common_data_source_types, :read
    end

    mutations do
      create :create_ofbiz_common_data_source_type, :create
      update :update_ofbiz_common_data_source_type, :update
      destroy :delete_ofbiz_common_data_source_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :data_source_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
