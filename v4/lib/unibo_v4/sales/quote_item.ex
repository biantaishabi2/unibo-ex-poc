# Workflow: quote_item_editing — 报价明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Sales.QuoteItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_quote_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :quote_unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :estimated_delivery_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :seq_id, :integer, public?: true
    attribute :is_promo, :boolean do
      default false
      public? true
    end
    attribute :lead_time_days, :integer, public?: true
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :line_amount, :decimal do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :quote, UniboV4.Sales.Quote do
      public? true
      allow_nil? false
    end
  end

  actions do
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :quote_unit_price, :comments, :estimated_delivery_date, :seq_id, :is_promo, :lead_time_days]
      argument :quote_id, :uuid, allow_nil?: false
      change manage_relationship(:quote_id, :quote, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        quote_unit_price = Ash.Changeset.get_attribute(changeset, :quote_unit_price)

        if quantity && quote_unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, quote_unit_price))
        else
          changeset
        end
      end
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
      accept [:quantity, :quote_unit_price, :comments, :estimated_delivery_date, :seq_id, :is_promo, :lead_time_days]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        quote_unit_price = Ash.Changeset.get_attribute(changeset, :quote_unit_price)

        if quantity && quote_unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, quote_unit_price))
        else
          changeset
        end
      end
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
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:quote_unit_price, greater_than_or_equal_to: 0)
  end

end
