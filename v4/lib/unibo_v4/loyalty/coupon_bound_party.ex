defmodule UniboV4.Loyalty.Loyalty.CouponBoundParty do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "loyalty_coupon_bound_parties"
    repo UniboV4.Repo
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
    attribute :bound_at, :utc_datetime, public?: true
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
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      argument :coupon_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
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
