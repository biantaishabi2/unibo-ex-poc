defmodule UniboExPoc.Ofbiz.Product.Subscription do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_subscriptions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription

    queries do
      get :get_product_subscription, :read
      list :list_product_subscriptions, :read
    end

    mutations do
      create :create_product_subscription, :create
      update :update_product_subscription, :update
      destroy :delete_product_subscription, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :subscription_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :communication_event_id, :string do
      public? true
      description "现已由以下实体替代：SubscriptionCommEvent"
    end
    attribute :contact_mech_id, :string, public?: true
    attribute :originated_from_party_id, :string, public?: true
    attribute :originated_from_role_type_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :party_need_id, :string, public?: true
    attribute :need_type_id, :string, public?: true
    attribute :order_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :external_subscription_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :purchase_from_date, :utc_datetime, public?: true
    attribute :purchase_thru_date, :utc_datetime, public?: true
    attribute :max_life_time, :integer do
      public? true
      description "（扩展）订阅的时间长度"
    end
    attribute :max_life_time_uom_id, :string, public?: true
    attribute :available_time, :integer, public?: true
    attribute :available_time_uom_id, :string, public?: true
    attribute :use_count_limit, :integer, public?: true
    attribute :use_time, :integer, public?: true
    attribute :use_time_uom_id, :string, public?: true
    attribute :automatic_extend, :boolean do
      public? true
      description "如果此订阅以与初始期限相同的期限自动续展"
    end
    attribute :cancl_autm_ext_time, :integer do
      public? true
      description "自动扩展订阅的时间段（在thruDate结束之前）"
    end
    attribute :cancl_autm_ext_time_uom_id, :string do
      public? true
      description "用于订阅自动扩展的计量单位"
    end
    attribute :grace_period_on_expiry, :integer do
      public? true
      description "自动扩展订阅的时间段（在thruDate结束之前）"
    end
    attribute :grace_period_on_expiry_uom_id, :string do
      public? true
      description "用于订阅自动扩展的计量单位"
    end
    attribute :expiration_completed_date, :utc_datetime do
      public? true
      description "过期完成的日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :subscription_resource, UniboExPoc.Ofbiz.Product.SubscriptionResource do
      public? true
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
    end
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Product.InventoryItem do
      public? true
    end
    belongs_to :subscription_type, UniboExPoc.Ofbiz.Product.SubscriptionType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
