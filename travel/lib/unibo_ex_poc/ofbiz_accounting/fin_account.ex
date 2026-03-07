defmodule UniboExPoc.Ofbiz.Accounting.FinAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account

    queries do
      get :get_accounting_fin_account, :read
      list :list_accounting_fin_accounts, :read
    end

    mutations do
      create :create_accounting_fin_account, :create
      update :update_accounting_fin_account, :update
      destroy :delete_accounting_fin_account, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fin_account_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :fin_account_name, :string, public?: true
    attribute :fin_account_code, :string, public?: true
    attribute :fin_account_pin, :string, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :organization_party_id, :string do
      public? true
      description "拥有（或说承担责任的）该账户的内部组织参与方。"
    end
    attribute :owner_party_id, :string do
      public? true
      description "拥有该账户的客户或第三方。"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "描述账户何时有效。如果为空，立即有效。"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "账户的过期日期。如果为空，永不过期。"
    end
    attribute :is_refundable, :boolean, public?: true
    attribute :replenish_level, :decimal, public?: true
    attribute :actual_balance, :decimal do
      public? true
      description "计算为FinAccountTrans.amount的总和"
    end
    attribute :available_balance, :decimal do
      public? true
      description "计算为实际余额减去未清FinAccountAuth.amount的总和"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fin_account_type, UniboExPoc.Ofbiz.Accounting.FinAccountType do
      public? true
    end
    belongs_to :post_to_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :replenish_payment_method, UniboExPoc.Ofbiz.Accounting.PaymentMethod do
      public? true
      source_attribute :replenish_payment_id
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
