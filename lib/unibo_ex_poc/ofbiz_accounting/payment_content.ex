defmodule UniboV4.Ofbiz.Accounting.PaymentContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_contents"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_content

    queries do
      get :get_accounting_payment_content, :read
      list :list_accounting_payment_contents, :read
    end

    mutations do
      create :create_accounting_payment_content, :create
      update :update_accounting_payment_content, :update
      destroy :delete_accounting_payment_content, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment, UniboV4.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :payment_content_type, UniboV4.Ofbiz.Accounting.PaymentContentType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
