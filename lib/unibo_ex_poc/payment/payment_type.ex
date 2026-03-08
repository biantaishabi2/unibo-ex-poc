# Workflow: payment_type_lifecycle — 支付类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Payment.PaymentType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "支付类型字典，区分收款/付款/薪资等方向与性质，支持父子层级"
  end

  postgres do
    table "payment_types"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_payment_type

    queries do
      get :get_payment_payment_type, :read
      list :list_payment_payment_types, :read
    end

    mutations do
      create :create_payment_payment_type, :create
      update :update_payment_payment_type, :update
      destroy :delete_payment_payment_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_type_id, :uuid do
      allow_nil? false
      public? true
      description "业务码，如 RECEIPT / DISBURSEMENT / PAYROLL_PAYMENT"
    end
    attribute :has_table, :boolean do
      default false
      public? true
      description "是否有扩展子表"
    end
    attribute :description, :string do
      public? true
      description "类型描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent, UniboV4.Payment.PaymentType do
      public? true
      source_attribute :parent_type_id
    end
    has_many :children, UniboV4.Payment.PaymentType do
      public? true
      source_attribute :parent_type_id
      destination_attribute :parent_type_id
    end
    has_many :payments, UniboV4.Payment.Payment do
      public? true
      source_attribute :payment_type_id
      destination_attribute :payment_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_type_id, :parent_type_id, :has_table, :description]
      validate present(:payment_type_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :has_table]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_payment_type_id, [:payment_type_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:children, :payments]
  end

end
