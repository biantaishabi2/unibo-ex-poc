defmodule UniboV4.Maintenance.ContractServiceItemLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "合同-服务项桥接占位实体"
  end

  postgres do
    table "maintenance_contract_service_item_links"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_contract_service_item_link

    queries do
      get :get_maintenance_contract_service_item_link, :read
      list :list_maintenance_contract_service_item_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :contract, UniboV4.Maintenance.Contract do
      public? true
      allow_nil? false
    end
    belongs_to :service_type, UniboV4.Maintenance.ServiceType do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
