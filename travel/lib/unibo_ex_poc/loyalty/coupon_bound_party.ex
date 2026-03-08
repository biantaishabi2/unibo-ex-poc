defmodule UniboExPoc.Loyalty.CouponBoundParty do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "专属优惠券与客户的绑定关系，private 类型优惠券只允许绑定客户使用"
  end

  postgres do
    table "loyalty_coupon_bound_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_coupon_bound_party

    queries do
      get :get_loyalty_coupon_bound_party, :read
      list :list_loyalty_coupon_bound_partys, :read
    end

    mutations do
      create :create_loyalty_coupon_bound_party, :create
      destroy :delete_loyalty_coupon_bound_party, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :bound_at, :utc_datetime do
      public? true
      description "绑定时间"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :coupon, UniboExPoc.Loyalty.Coupon do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Loyalty.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      argument :coupon_id, :uuid, allow_nil?: false
      argument :partner_party_id, :uuid, allow_nil?: false
      change manage_relationship(:coupon_id, :coupon, type: :append, on_lookup: :relate)
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
