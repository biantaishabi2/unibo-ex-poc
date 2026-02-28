defmodule UniboV4.Accounting.InvoiceItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "invoice_items"
    repo UniboV4.Repo
  end

  graphql do
    type :invoice_item

    mutations do
      create :create_invoice_item, :create
      update :update_invoice_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string, allow_nil?: false
    attribute :quantity, :integer, allow_nil?: false
    attribute :unit_price, :decimal, allow_nil?: false
    attribute :amount, :decimal, allow_nil?: false
    attribute :tax_rate, :decimal, default: 0
    attribute :tax_amount, :decimal, default: 0
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :invoice, UniboV4.Accounting.Invoice do
      allow_nil? false
    end
    belongs_to :gl_account, UniboV4.Accounting.GlAccount
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :quantity, :unit_price, :tax_rate]
      argument :gl_account_id, :uuid
      argument :invoice_id, :uuid, allow_nil?: false
      change manage_relationship(:invoice_id, :invoice, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :amount, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
      change fn changeset, _context ->
        amount = Ash.Changeset.get_attribute(changeset, :amount)
        tax_rate = Ash.Changeset.get_attribute(changeset, :tax_rate)

        if amount && tax_rate do
          Ash.Changeset.force_change_attribute(changeset, :tax_amount, Decimal.div(Decimal.mult(amount, tax_rate), 100))
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :tax_rate]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :amount, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
      change fn changeset, _context ->
        amount = Ash.Changeset.get_attribute(changeset, :amount)
        tax_rate = Ash.Changeset.get_attribute(changeset, :tax_rate)

        if amount && tax_rate do
          Ash.Changeset.force_change_attribute(changeset, :tax_amount, Decimal.div(Decimal.mult(amount, tax_rate), 100))
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:unit_price, greater_than_or_equal_to: 0)
  end

end
