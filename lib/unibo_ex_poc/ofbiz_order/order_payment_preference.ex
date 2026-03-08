defmodule UniboV4.Ofbiz.Order.OrderPaymentPreference do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_payment_preferences"
    repo UniboV4.Repo
  end

  graphql do
    type :order_order_payment_preference

    queries do
      get :get_order_order_payment_preference, :read
      list :list_order_order_payment_preferences, :read
    end

    mutations do
      create :create_order_order_payment_preference, :create
      update :update_order_order_payment_preference, :update
      destroy :delete_order_order_payment_preference, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_payment_preference_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :ship_group_seq_id, :string, public?: true
    attribute :product_price_purpose_id, :string, public?: true
    attribute :payment_method_type_id, :string, public?: true
    attribute :payment_method_id, :string, public?: true
    attribute :fin_account_id, :string do
      public? true
      description "使用金融账户而不是存档的付款方式进行支付"
    end
    attribute :security_code, :string do
      public? true
      description "注意：此字段不应在单个事务范围之外持久化，通常仅用于授权目的，使用后应立即移除；这是背面的3位（用于Visa、MC等）或前面的4位（Amex等）卡验证码；另请注意，此字段的长度超过所需长度以容纳加密"
    end
    attribute :track2, :string do
      public? true
      description "注意：此字段不应在单个事务范围之外持久化，通常仅用于授权目的，使用后应立即移除；这是原始track2数据，完全按照磁条读卡器读取的方式；另请注意，此字段的长度超过所需长度以容纳加密"
    end
    attribute :present_flag, :boolean, public?: true
    attribute :swiped_flag, :boolean, public?: true
    attribute :overflow_flag, :boolean, public?: true
    attribute :max_amount, :decimal, public?: true
    attribute :process_attempt, :integer, public?: true
    attribute :billing_postal_code, :string, public?: true
    attribute :manual_auth_code, :string, public?: true
    attribute :manual_ref_num, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :needs_nsf_retry, :boolean, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboV4.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
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
