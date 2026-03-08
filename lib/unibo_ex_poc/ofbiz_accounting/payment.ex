defmodule UniboV4.Ofbiz.Accounting.Payment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payments"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment

    queries do
      get :get_accounting_payment, :read
      list :list_accounting_payments, :read
    end

    mutations do
      create :create_accounting_payment, :create
      update :update_accounting_payment, :update
      destroy :delete_accounting_payment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_id, :string, public?: true
    attribute :payment_preference_id, :string, public?: true
    attribute :party_id_from, :string, public?: true
    attribute :party_id_to, :string, public?: true
    attribute :role_type_id_to, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :effective_date, :utc_datetime, public?: true
    attribute :payment_ref_num, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :actual_currency_amount, :decimal, public?: true
    attribute :actual_currency_uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_type, UniboV4.Ofbiz.Accounting.PaymentType do
      public? true
    end
    belongs_to :payment_method_type, UniboV4.Ofbiz.Accounting.PaymentMethodType do
      public? true
    end
    belongs_to :payment_method, UniboV4.Ofbiz.Accounting.PaymentMethod do
      public? true
    end
    belongs_to :credit_card, UniboV4.Ofbiz.Accounting.CreditCard do
      public? true
      source_attribute :payment_method_id
      define_attribute? false
    end
    belongs_to :eft_account, UniboV4.Ofbiz.Accounting.EftAccount do
      public? true
      source_attribute :payment_method_id
      define_attribute? false
    end
    belongs_to :gift_card, UniboV4.Ofbiz.Accounting.GiftCard do
      public? true
      source_attribute :payment_method_id
      define_attribute? false
    end
    belongs_to :payment_gateway_response, UniboV4.Ofbiz.Accounting.PaymentGatewayResponse do
      public? true
    end
    belongs_to :fin_account_trans, UniboV4.Ofbiz.Accounting.FinAccountTrans do
      public? true
    end
    belongs_to :gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
      public? true
      source_attribute :override_gl_account_id
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
