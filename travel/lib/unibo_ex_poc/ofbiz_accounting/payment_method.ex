defmodule UniboExPoc.Ofbiz.Accounting.PaymentMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_method

    queries do
      get :get_ofbiz_accounting_payment_method, :read
      list :list_ofbiz_accounting_payment_methods, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_method, :create
      update :update_ofbiz_accounting_payment_method, :update
      destroy :delete_ofbiz_accounting_payment_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method_type, UniboExPoc.Ofbiz.Accounting.PaymentMethodType do
      public? true
    end
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :fin_account, UniboExPoc.Ofbiz.Accounting.FinAccount do
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
