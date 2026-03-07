defmodule UniboExPoc.Ofbiz.Accounting.FinAccountTrans do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_transes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account_trans

    queries do
      get :get_accounting_fin_account_trans, :read
      list :list_accounting_fin_account_transs, :read
    end

    mutations do
      create :create_accounting_fin_account_trans, :create
      update :update_accounting_fin_account_trans, :update
      destroy :delete_accounting_fin_account_trans, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fin_account_trans_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :transaction_date, :utc_datetime, public?: true
    attribute :entry_date, :utc_datetime, public?: true
    attribute :amount, :decimal, public?: true
    attribute :order_id, :string, public?: true
    attribute :order_item_seq_id, :string do
      public? true
      description "与订单编号一起使用，指向表示购买产品以向账户添加资金的订单项"
    end
    attribute :performed_by_party_id, :string, public?: true
    attribute :reason_enum_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fin_account_trans_type, UniboExPoc.Ofbiz.Accounting.FinAccountTransType do
      public? true
    end
    belongs_to :fin_account, UniboExPoc.Ofbiz.Accounting.FinAccount do
      public? true
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :gl_reconciliation, UniboExPoc.Ofbiz.Accounting.GlReconciliation do
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
