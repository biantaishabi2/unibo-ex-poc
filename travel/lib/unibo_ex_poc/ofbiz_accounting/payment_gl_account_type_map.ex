defmodule UniboExPoc.Ofbiz.Accounting.PaymentGlAccountTypeMap do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gl_account_type_maps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gl_account_type_map

    queries do
      get :get_accounting_payment_gl_account_type_map, :read
      list :list_accounting_payment_gl_account_type_maps, :read
    end

    mutations do
      create :create_accounting_payment_gl_account_type_map, :create
      update :update_accounting_payment_gl_account_type_map, :update
      destroy :delete_accounting_payment_gl_account_type_map, :destroy
    end

  end

  attributes do
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_type, UniboExPoc.Ofbiz.Accounting.PaymentType do
      public? true
    end
    belongs_to :gl_account_type, UniboExPoc.Ofbiz.Accounting.GlAccountType do
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
