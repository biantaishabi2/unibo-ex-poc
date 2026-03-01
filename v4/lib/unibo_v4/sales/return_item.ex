# Workflow: return_item_editing — 退货明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Sales.ReturnItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sales_return_items"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_return_item

    mutations do
      create :create_sales_return_item, :create
      update :update_sales_return_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity, :integer do
      allow_nil? false
      public? true
    end
    attribute :return_reason, :string, public?: true
    attribute :refund_amount, :decimal do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :return, UniboV4.Sales.Return do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :quantity, :return_reason, :refund_amount]
      argument :return_id, :uuid, allow_nil?: false
      change manage_relationship(:return_id, :return, type: :append, on_lookup: :relate)
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
      accept [:quantity, :refund_amount]
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
    validate compare(:refund_amount, greater_than_or_equal_to: 0)
  end

end
