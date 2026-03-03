# Workflow: payment_creation — POS 支付创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.POS.PosPayment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_payments"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_pos_payment

    queries do
      get :get_pos_pos_payment, :read
      list :list_pos_pos_payments, :read
    end

    mutations do
      create :create_pos_pos_payment, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :is_change, :boolean do
      default false
      public? true
    end
    attribute :reference_number, :string, public?: true
    attribute :card_type, :string, public?: true
    attribute :cardholder_name, :string, public?: true
    attribute :transaction_id, :string, public?: true
    attribute :payment_status, :string, public?: true
    attribute :ticket, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboV4.POS.PosOrder do
      public? true
      allow_nil? false
    end
    belongs_to :payment_method, UniboV4.POS.PosPaymentMethod do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:amount, :is_change, :reference_number, :card_type, :cardholder_name, :transaction_id, :payment_status, :ticket]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :payment_method_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_method_id, :payment_method, type: :append, on_lookup: :relate)
      # TODO: 不支持的 change effect side_effect
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
    # TODO: 不支持的校验规则 custom
    # TODO: 不支持的校验规则 custom
  end

end
