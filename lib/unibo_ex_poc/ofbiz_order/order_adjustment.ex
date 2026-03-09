defmodule UniboExPoc.Ofbiz.Order.OrderAdjustment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "注意：includeInTax 和 includeInShipping 应默认为 true，但当调整为税收或运费调整时应被忽略"
  end

  postgres do
    table "order_adjustments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_adjustment

    queries do
      get :get_order_order_adjustment, :read
      list :list_order_order_adjustments, :read
    end

    mutations do
      create :create_order_order_adjustment, :create
      update :update_order_order_adjustment, :update
      destroy :delete_order_order_adjustment, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_adjustment_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :ship_group_seq_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :description, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :recurring_amount, :decimal, public?: true
    attribute :amount_already_included, :decimal do
      public? true
      description "此处的金额已在价格中表示，例如增值税"
    end
    attribute :product_promo_id, :string, public?: true
    attribute :product_promo_rule_id, :string, public?: true
    attribute :product_promo_action_seq_id, :string, public?: true
    attribute :product_feature_id, :string, public?: true
    attribute :corresponding_product_id, :string, public?: true
    attribute :tax_authority_rate_seq_id, :string, public?: true
    attribute :source_reference_id, :string, public?: true
    attribute :source_percentage, :decimal do
      public? true
      description "对于税收条目，这是税收百分比"
    end
    attribute :customer_reference_id, :string do
      public? true
      description "对于税收条目，这是交易方税务ID"
    end
    attribute :primary_geo_id, :string do
      public? true
      description "对于税收条目，这是主要管辖区Geo（税收所适用的最小或最本地Geo，通常是州/省，也许是县或市）"
    end
    attribute :secondary_geo_id, :string do
      public? true
      description "对于税收条目，这是次要管辖区Geo（通常是国家或主要Geo所在的其他Geo）"
    end
    attribute :exempt_amount, :decimal do
      public? true
      description "通常应适用但不适用于此订单的金额；对于税收豁免，表示税款本应为的金额"
    end
    attribute :tax_auth_geo_id, :string do
      public? true
      description "这些taxAuth字段已弃用primaryGeoId和secondaryGeoId字段，将用于较新的税收计算"
    end
    attribute :tax_auth_party_id, :string, public?: true
    attribute :override_gl_account_id, :string do
      public? true
      description "用于指定用于调整的覆盖或实际glAccountId，避免初始过账后配置更改引发的问题等"
    end
    attribute :include_in_tax, :boolean, public?: true
    attribute :include_in_shipping, :boolean, public?: true
    attribute :is_manual, :boolean, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_adjustment_type, UniboExPoc.Ofbiz.Order.OrderAdjustmentType do
      public? true
      attribute_type :string
    end
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :order_adjustment, UniboExPoc.Ofbiz.Order.OrderAdjustment do
      public? true
      source_attribute :original_adjustment_id
      attribute_type :string
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
