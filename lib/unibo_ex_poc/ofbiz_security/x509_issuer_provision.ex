defmodule UniboV4.Ofbiz.Security.X509IssuerProvision do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Valid issuer data for authentication of x.509 certificates"
  end

  postgres do
    table "security_x509_issuer_provisions"
    repo UniboV4.Repo
  end

  graphql do
    type :security_x509_issuer_provision

    queries do
      get :get_security_x509_issuer_provision, :read
      list :list_security_x509_issuer_provisions, :read
    end

    mutations do
      create :create_security_x509_issuer_provision, :create
      update :update_security_x509_issuer_provision, :update
      destroy :delete_security_x509_issuer_provision, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :cert_provision_id, :string, public?: true
    attribute :common_name, :string, public?: true
    attribute :organizational_unit, :string, public?: true
    attribute :organization_name, :string, public?: true
    attribute :city_locality, :string, public?: true
    attribute :state_province, :string, public?: true
    attribute :country, :string, public?: true
    attribute :serial_number, :string, public?: true
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
