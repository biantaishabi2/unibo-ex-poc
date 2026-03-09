defmodule UniboExPoc.Loyalty.CouponUsage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "优惠券核销记录，追踪每次使用的客户、订单、实际折扣金额"
  end

  postgres do
    table "loyalty_coupon_usages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_coupon_usage

    queries do
      get :get_loyalty_coupon_usage, :read
      list :list_loyalty_coupon_usages, :read
    end

    mutations do
      create :create_loyalty_coupon_usage, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :used_at, :utc_datetime do
      allow_nil? false
      public? true
      description "使用时间"
    end
    attribute :discount_amount, :decimal do
      public? true
      description "实际折扣金额（映射 ProductPromoUse.total_discount_amount）"
    end
    attribute :order_amount, :decimal do
      public? true
      description "订单原始金额"
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :coupon, UniboExPoc.Loyalty.Coupon do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:used_at, :discount_amount, :order_amount]
      argument :coupon_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      argument :order_id, :uuid
      change manage_relationship(:coupon_id, :coupon, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
  end

end
