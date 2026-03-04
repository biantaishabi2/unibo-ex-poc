# Workflow: payment_application_lifecycle — 付款核销生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Accounting.PaymentApplication do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_payment_applications"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :applied_amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
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
    defaults [:read, :destroy]
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

end
