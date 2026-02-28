defmodule UniboV4.Sales.QuoteItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quote_items"
    repo UniboV4.Repo
  end

  graphql do
    type :quote_item

    mutations do
      create :create_quote_item, :create
      update :update_quote_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :product_code, :string
    attribute :quantity, :integer, allow_nil?: false
    attribute :unit_price, :decimal, allow_nil?: false
    attribute :line_amount, :decimal, allow_nil?: false
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :quote, UniboV4.Sales.Quote do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :unit_price, :description]
      argument :quote_id, :uuid, allow_nil?: false
      change manage_relationship(:quote_id, :quote, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :description]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, unit_price))
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
