defmodule UniboExPoc.Ofbiz.Accounting.FinAccountStatus do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account_status

    queries do
      get :get_accounting_fin_account_status, :read
      list :list_accounting_fin_account_statuss, :read
    end

    mutations do
      create :create_accounting_fin_account_status, :create
      update :update_accounting_fin_account_status, :update
      destroy :delete_accounting_fin_account_status, :destroy
    end

  end

  attributes do
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_end_date, :utc_datetime, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fin_account, UniboExPoc.Ofbiz.Accounting.FinAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
