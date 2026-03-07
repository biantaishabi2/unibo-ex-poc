defmodule UniboExPoc.Ofbiz.Accounting.GlAccountHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_histories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_history

    queries do
      get :get_accounting_gl_account_history, :read
      list :list_accounting_gl_account_historys, :read
    end

    mutations do
      create :create_accounting_gl_account_history, :create
      update :update_accounting_gl_account_history, :update
      destroy :delete_accounting_gl_account_history, :destroy
    end

  end

  attributes do
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :custom_time_period_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :opening_balance, :decimal, public?: true
    attribute :posted_debits, :decimal, public?: true
    attribute :posted_credits, :decimal, public?: true
    attribute :ending_balance, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
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
