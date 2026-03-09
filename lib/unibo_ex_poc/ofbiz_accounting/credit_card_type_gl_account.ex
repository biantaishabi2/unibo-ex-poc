defmodule UniboExPoc.Ofbiz.Accounting.CreditCardTypeGlAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_credit_card_type_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_credit_card_type_gl_account

    queries do
      get :get_accounting_credit_card_type_gl_account, :read
      list :list_accounting_credit_card_type_gl_accounts, :read
    end

    mutations do
      create :create_accounting_credit_card_type_gl_account, :create
      update :update_accounting_credit_card_type_gl_account, :update
      destroy :delete_accounting_credit_card_type_gl_account, :destroy
    end

  end

  attributes do
    attribute :card_type, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :gl_account_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
