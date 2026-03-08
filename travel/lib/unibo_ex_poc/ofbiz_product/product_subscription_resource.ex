defmodule UniboExPoc.Ofbiz.Product.ProductSubscriptionResource do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_product_subscription_resources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_subscription_resource

    queries do
      get :get_product_product_subscription_resource, :read
      list :list_product_product_subscription_resources, :read
    end

    mutations do
      create :create_product_product_subscription_resource, :create
      update :update_product_product_subscription_resource, :update
      destroy :delete_product_product_subscription_resource, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :purchase_from_date, :utc_datetime, public?: true
    attribute :purchase_thru_date, :utc_datetime, public?: true
    attribute :max_life_time, :integer do
      public? true
      description "订阅的时间长度"
    end
    attribute :max_life_time_uom_id, :string, public?: true
    attribute :available_time, :integer, public?: true
    attribute :available_time_uom_id, :string, public?: true
    attribute :use_count_limit, :integer, public?: true
    attribute :use_time, :integer do
      public? true
      description "此订阅可使用的时间长度"
    end
    attribute :use_time_uom_id, :string, public?: true
    attribute :use_role_type_id, :string, public?: true
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
      description "订阅过期的时间段（在thruDate结束之后）"
    end
    attribute :grace_period_on_expiry_uom_id, :string do
      public? true
      description "用于订阅宽限期的计量单位"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :subscription_resource, UniboExPoc.Ofbiz.Product.SubscriptionResource do
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
