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
defmodule UniboV4.Payment.PaymentApplication do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "payment_applications"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_item_seq_id, :string, public?: true
    attribute :billing_account_id, :string, public?: true
    attribute :override_gl_account_id, :string, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :amount_applied, :decimal do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :payment, UniboV4.Payment.Payment do
      public? true
      allow_nil? false
    end
    belongs_to :to_payment, UniboV4.Payment.Payment do
      public? true
    end
    belongs_to :invoice, UniboV4.Payment.Invoice do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:invoice_item_seq_id, :billing_account_id, :override_gl_account_id, :tax_auth_geo_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:amount_applied, :override_gl_account_id]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    create :apply_to_invoice do
      accept [:invoice_item_seq_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
      validate present(:invoice_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    create :apply_to_account do
      accept [:billing_account_id, :amount_applied]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount_applied)
      validate present(:billing_account_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:amount_applied, greater_than: 0)
  end

end
