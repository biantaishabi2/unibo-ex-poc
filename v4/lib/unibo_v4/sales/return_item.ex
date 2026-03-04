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
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_return_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :return_item_type_id, :string, public?: true
    attribute :return_reason, :string, public?: true
    attribute :return_type, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :return_quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :received_quantity, :decimal, public?: true
    attribute :return_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :refund_amount, :decimal, public?: true
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
    create :create do
      primary? true
      accept [:product_name, :description, :return_quantity, :return_price, :refund_amount, :return_reason, :return_type, :return_item_type_id, :status_id]
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
      accept [:return_quantity, :return_price, :refund_amount, :received_quantity, :status_id]
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
    validate compare(:return_quantity, greater_than: 0)
    validate compare(:return_price, greater_than_or_equal_to: 0)
  end

end
