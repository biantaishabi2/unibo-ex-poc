defmodule UniboV4.POS.PosOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_order

    queries do
      get :get_pos_order, :read
      list :list_pos_orders, :read
    end

    mutations do
      create :create_pos_order, :create
      update :pay_pos_order, :pay
      update :refund_pos_order, :refund
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :paid, :refunded, :cancelled]
      default :draft
        public? true
    end
    attribute :total_amount, :decimal, allow_nil?: false, public?: true
    attribute :tax_amount, :decimal, default: 0, public?: true
    attribute :discount_amount, :decimal, default: 0, public?: true
    attribute :order_date, :utc_datetime, allow_nil?: false, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.POS.PosOrderLine
    has_many :payments, UniboV4.POS.PosPayment
    belongs_to :session, UniboV4.POS.PosSession do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :order_date, :discount_amount, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :session_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:session_id, :session, type: :append, on_lookup: :relate)
      validate present(:order_number)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :pay do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以付款"
      end
      change set_attribute(:status, :paid)
    end
    update :refund do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :paid) do
        message "只有已付款状态可以退款"
      end
      change set_attribute(:status, :refunded)
    end
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

end
