defmodule UniboV4.Sales.ReturnItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "return_items"
    repo UniboV4.Repo
  end

  graphql do
    type :return_item

    mutations do
      create :create_return_item, :create
      update :update_return_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :quantity, :integer, allow_nil?: false
    attribute :return_reason, :string
    attribute :refund_amount, :decimal, allow_nil?: false
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :return, UniboV4.Sales.Return do
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
    end
    update :update do
      primary? true
      accept [:quantity, :refund_amount]
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:refund_amount, greater_than_or_equal_to: 0)
  end

end
