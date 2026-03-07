defmodule UniboExPoc.Ofbiz.Accounting.PaymentAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_attribute

    queries do
      get :get_accounting_payment_attribute, :read
      list :list_accounting_payment_attributes, :read
    end

    mutations do
      create :create_accounting_payment_attribute, :create
      update :update_accounting_payment_attribute, :update
      destroy :delete_accounting_payment_attribute, :destroy
    end

  end

  attributes do
    attribute :payment_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
