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
    type :pos_payment

    queries do
      get :get_pos_payment, :read
      list :list_pos_payments, :read
    end

    mutations do
      create :create_pos_payment, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method, :atom do
      allow_nil? false
      constraints one_of: [:cash, :credit_card, :debit_card, :wechat, :alipay, :other]
    end
    attribute :amount, :decimal, allow_nil?: false
    attribute :reference_number, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboV4.POS.PosOrder do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:payment_method, :amount, :reference_number]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

end
