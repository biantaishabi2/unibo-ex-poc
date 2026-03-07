defmodule UniboExPoc.Ofbiz.Common.TelecomGatewayConfig do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Telecom Gateway Config"
  end

  postgres do
    table "common_telecom_gateway_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_telecom_gateway_config

    queries do
      get :get_common_telecom_gateway_config, :read
      list :list_common_telecom_gateway_configs, :read
    end

    mutations do
      create :create_common_telecom_gateway_config, :create
      update :update_common_telecom_gateway_config, :update
      destroy :delete_common_telecom_gateway_config, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :telecom_gateway_config_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
