defmodule UniboV4.Ofbiz.Accounting.PaymentMethodType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_method_types"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_method_type

    queries do
      get :get_accounting_payment_method_type, :read
      list :list_accounting_payment_method_types, :read
    end

    mutations do
      create :create_accounting_payment_method_type, :create
      update :update_accounting_payment_method_type, :update
      destroy :delete_accounting_payment_method_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :default_gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
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
