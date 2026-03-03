# Workflow: coupon_lifecycle_flow — 优惠券发放-使用-核销完整流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> apply
#   create --> cancel_coupon
#   update --> update
#   update --> apply
#   update --> cancel_coupon
#   apply --> apply
#   apply --> cancel_coupon
#   cancel_coupon --> [*] : cancelled
# ```
defmodule UniboV4.Loyalty.Loyalty.Coupon do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Loyalty.Loyalty.Coupon.Notifier]

  postgres do
    table "loyalty_coupons"
    repo UniboV4.Repo
  end

  graphql do
    type :loyalty_coupon

    queries do
      get :get_loyalty_coupon, :read
      list :list_loyalty_coupons, :read
    end

    mutations do
      create :create_loyalty_coupon, :create
      update :update_loyalty_coupon, :update
      update :apply_loyalty_coupon, :apply
      update :cancel_coupon_loyalty_coupon, :cancel_coupon
      destroy :delete_loyalty_coupon, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :coupon_type, :atom do
      allow_nil? false
      constraints one_of: [:public, :private, :one_time]
      default :public
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :used, :expired, :cancelled]
      default :active
      public? true
    end
    attribute :discount_type, :atom do
      constraints one_of: [:percent, :fixed, :free_shipping]
      public? true
    end
    attribute :discount_value, :decimal, public?: true
    attribute :min_order_amount, :decimal, public?: true
    attribute :max_discount_amount, :decimal, public?: true
    attribute :use_limit_per_code, :integer, public?: true
    attribute :use_limit_per_customer, :integer do
      default 1
      public? true
    end
    attribute :used_count, :integer do
      default 0
      public? true
    end
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :require_email_or_party, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :actual_discount
    # TODO: 不支持的 calculation 表达式 :is_expired
  end

  relationships do
    belongs_to :program, UniboV4.Loyalty.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :usages, UniboV4.Loyalty.Loyalty.CouponUsage do
      public? true
      destination_attribute :coupon_id
    end
    has_many :bound_partners, UniboV4.Loyalty.Loyalty.CouponBoundParty do
      public? true
      destination_attribute :coupon_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:code, :coupon_type, :discount_type, :discount_value, :min_order_amount, :max_discount_amount, :use_limit_per_code, :use_limit_per_customer, :from_date, :thru_date, :require_email_or_party]
      argument :program_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      validate present(:code)
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
      accept [:discount_value, :min_order_amount, :use_limit_per_code, :thru_date]
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
    update :apply do
      accept [:used_count]
      argument :order_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      # TODO: 不支持的 change effect increment
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
    update :cancel_coupon do
      accept []
      change set_attribute(:status, :cancelled)
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
    # TODO: 不支持的校验规则 unique
    validate compare(:discount_value, greater_than: 0)
  end

end
