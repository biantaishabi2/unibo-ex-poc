defmodule UniboV4.Loyalty.Loyalty.CouponUsage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "loyalty_coupon_usages"
    repo UniboV4.Repo
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
    end
    attribute :discount_amount, :decimal, public?: true
    attribute :order_amount, :decimal, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :coupon, UniboV4.Loyalty.Loyalty.Coupon do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Loyalty.Loyalty.ResPartner do
      public? true
      allow_nil? false
    end
    belongs_to :order, UniboV4.Loyalty.Loyalty.SaleOrder do
      public? true
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
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
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

end
