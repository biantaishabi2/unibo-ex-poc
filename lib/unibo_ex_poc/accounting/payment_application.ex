# Workflow: payment_application_lifecycle — 付款核销生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Accounting.PaymentApplication do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "付款与发票的核销关系"
  end

  postgres do
    table "accounting_payment_applications"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_application

    queries do
      get :get_accounting_payment_application, :read
      list :list_accounting_payment_applications, :read
    end

    mutations do
      create :create_accounting_payment_application, :create
      destroy :delete_accounting_payment_application, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :applied_amount, :decimal do
      allow_nil? false
      public? true
      description "核销金额"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment, UniboV4.Accounting.Payment do
      public? true
      allow_nil? false
    end
    belongs_to :invoice, UniboV4.Accounting.Invoice do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:applied_amount, :notes]
      argument :payment_id, :uuid, allow_nil?: false
      argument :invoice_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      change manage_relationship(:invoice_id, :invoice, type: :append, on_lookup: :relate)
      validate compare(:applied_amount, greater_than: 0)
      # message: "核销金额必须大于零"
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
