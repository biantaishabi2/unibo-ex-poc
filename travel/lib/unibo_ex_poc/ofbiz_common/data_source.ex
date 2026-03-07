defmodule UniboExPoc.Ofbiz.Common.DataSource do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Data Source"
  end

  postgres do
    table "common_data_sources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_data_source

    queries do
      get :get_common_data_source, :read
      list :list_common_data_sources, :read
    end

    mutations do
      create :create_common_data_source, :create
      update :update_common_data_source, :update
      destroy :delete_common_data_source, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :data_source_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_source_type, UniboExPoc.Ofbiz.Common.DataSourceType do
      public? true
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
