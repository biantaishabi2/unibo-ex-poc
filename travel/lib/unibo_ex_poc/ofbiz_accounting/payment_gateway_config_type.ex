defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfigType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_config_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_gateway_config_type

    queries do
      get :get_ofbiz_accounting_payment_gateway_config_type, :read
      list :list_ofbiz_accounting_payment_gateway_config_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_gateway_config_type, :create
      update :update_ofbiz_accounting_payment_gateway_config_type, :update
      destroy :delete_ofbiz_accounting_payment_gateway_config_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_gateway_config_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_payment_gateway_config_type, UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfigType do
      public? true
      source_attribute :parent_type_id
    end
    has_many :sibling_payment_gateway_config_type, UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfigType do
      public? true
      source_attribute :parent_type_id
      destination_attribute :parent_type_id
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
    archive_related [:sibling_payment_gateway_config_type]
  end

end
