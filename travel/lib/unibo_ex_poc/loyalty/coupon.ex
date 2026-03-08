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
defmodule UniboExPoc.Loyalty.Coupon do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Loyalty.Coupon.Notifier]

  resource do
    description "优惠券，携带唯一码、有效期、使用次数限制，支持通用码与专属码两种模式"
  end

  postgres do
    table "loyalty_coupons"
    repo UniboExPoc.Repo
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
      description "优惠码（映射 ProductPromoCode.product_promo_code_id，唯一索引）"
    end
    attribute :coupon_type, :atom do
      allow_nil? false
      constraints one_of: [:public, :private, :one_time]
      default :public
      public? true
      description "券类型（public=通用码/private=专属码需绑定用户/one_time=一次性）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :used, :expired, :cancelled]
      default :active
      public? true
      description "券状态"
    end
    attribute :discount_type, :atom do
      constraints one_of: [:percent, :fixed, :free_shipping]
      public? true
      description "折扣方式"
    end
    attribute :discount_value, :decimal do
      public? true
      description "折扣值（百分比或固定金额）"
    end
    attribute :min_order_amount, :decimal do
      public? true
      description "最低使用门槛"
    end
    attribute :max_discount_amount, :decimal do
      public? true
      description "最大折扣上限"
    end
    attribute :use_limit_per_code, :integer do
      public? true
      description "全局使用次数上限（映射 ProductPromoCode.use_limit_per_code）"
    end
    attribute :use_limit_per_customer, :integer do
      default 1
      public? true
      description "每客户使用次数上限（映射 ProductPromoCode.use_limit_per_customer）"
    end
    attribute :used_count, :integer do
      default 0
      public? true
      description "已使用次数"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "生效时间（映射 ProductPromoCode.from_date）"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "过期时间（映射 ProductPromoCode.thru_date）"
    end
    attribute :require_email_or_party, :boolean do
      default false
      public? true
      description "是否要求绑定邮件/客户（映射 ProductPromoCode.require_email_or_party）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :actual_discount, :decimal, expr(compute_actual_discount(discount_type, discount_value, max_discount_amount))
    calculate :is_expired, :boolean, expr(check_coupon_expired(thru_date))
  end

  relationships do
    belongs_to :program, UniboExPoc.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :usages, UniboExPoc.Loyalty.CouponUsage do
      public? true
      source_attribute :program_id
      destination_attribute :coupon_id
    end
    has_many :bound_partners, UniboExPoc.Loyalty.CouponBoundParty do
      public? true
      source_attribute :program_id
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
      description "核销优惠券（校验有效性 + 增加 used_count）"
      accept [:used_count]
      argument :order_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :used_count) || 0
        Ash.Changeset.force_change_attribute(changeset, :used_count, current + 1)
      end
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
      description "作废优惠券（active -> cancelled）"
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
    validate compare(:discount_value, greater_than: 0)
  end

  identities do
    identity :unique_coupon_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:usages, :bound_partners]
  end

end
