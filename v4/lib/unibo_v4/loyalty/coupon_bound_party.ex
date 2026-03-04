defmodule UniboV4.Loyalty.CouponBoundParty do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "loyalty_coupon_bound_parties"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :bound_at, :utc_datetime, public?: true
  end

  relationships do
    belongs_to :coupon, UniboV4.Loyalty.Coupon do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      argument :coupon_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:coupon_id, :coupon, type: :append, on_lookup: :relate)
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
