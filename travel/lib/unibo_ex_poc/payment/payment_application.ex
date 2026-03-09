# Workflow: payment_application_flow — 支付核销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   apply_to_invoice --> update
#   apply_to_invoice --> destroy
#   apply_to_account --> update
#   apply_to_account --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Payment.PaymentApplication do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "支付核销记录，关联一笔支付到一张或多张发票（或另一笔支付），支持部分核销"
  end

  postgres do
    table "payment_applications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment_application

    queries do
      get :get_payment_payment_application, :read
      list :list_payment_payment_applications, :read
    end

    mutations do
      create :create_create_payment_payment_application, :create
      create :create_apply_to_invoice_payment_payment_application, :apply_to_invoice
      create :create_apply_to_account_payment_payment_application, :apply_to_account
      update :update_payment_payment_application, :update
      destroy :delete_payment_payment_application, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_item_seq_id, :string do
      public? true
      description "发票行项目序号（精确到行级核销）"
    end
    attribute :billing_account_id, :string do
      public? true
      description "核销到账单账户"
    end
    attribute :override_gl_account_id, :string do
      public? true
      description "直接过账的总账科目（跳过发票）"
    end
    attribute :tax_auth_geo_id, :string do
      public? true
      description "税务管辖区"
    end
    attribute :amount_applied, :decimal do
      allow_nil? false
      public? true
      description "本次核销金额"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment, UniboExPoc.Payment.Payment do
      public? true
      allow_nil? false
    end
    belongs_to :to_payment, UniboExPoc.Payment.Payment do
      public? true
    end
    belongs_to :invoice, UniboExPoc.Payment.Invoice do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_id, :invoice_id, :invoice_item_seq_id, :billing_account_id, :to_payment_id, :override_gl_account_id, :tax_auth_geo_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
    end
    update :update do
      primary? true
      accept [:amount_applied, :override_gl_account_id]
      require_atomic? false
    end
    create :apply_to_invoice do
      description "将支付核销到指定发票（或发票行）"
      accept [:payment_id, :invoice_id, :invoice_item_seq_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
      validate present(:invoice_id)
    end
    create :apply_to_account do
      description "将支付核销到账单账户（余额充值）"
      accept [:payment_id, :billing_account_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
      validate present(:billing_account_id)
    end
  end

  validations do
    validate compare(:amount_applied, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
