defmodule UniboV4.Ofbiz.Product.ProductStoreFinActSetting do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_fin_act_settings"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_store_fin_act_setting

    queries do
      get :get_product_product_store_fin_act_setting, :read
      list :list_product_product_store_fin_act_settings, :read
    end

    mutations do
      create :create_product_product_store_fin_act_setting, :create
      update :update_product_product_store_fin_act_setting, :update
      destroy :delete_product_product_store_fin_act_setting, :destroy
    end

  end

  attributes do
    attribute :fin_account_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :require_pin_code, :boolean, public?: true
    attribute :validate_gc_fin_acct, :boolean do
      public? true
      description "确定商店是否应根据FinAccount中存储的礼品卡代码验证礼品卡号。如果使用外部礼品卡提供商，请设置为N。"
    end
    attribute :account_code_length, :integer do
      public? true
      description "自动生成的账户代码长度"
    end
    attribute :pin_code_length, :integer do
      public? true
      description "自动生成的PIN码长度（如果需要）"
    end
    attribute :account_valid_days, :integer do
      public? true
      description "此类账户的有效天数"
    end
    attribute :auth_valid_days, :integer do
      public? true
      description "此类授权的有效天数"
    end
    attribute :purchase_survey_id, :string do
      public? true
      description "此调查通常用于收集信息，如买方名称、收件人、电子邮件、消息等，并且非常灵活"
    end
    attribute :purch_survey_send_to, :string do
      public? true
      description "购买调查上的字段名称，用于发送到电子邮件地址"
    end
    attribute :purch_survey_copy_me, :string do
      public? true
      description "是否应为电子邮件通知复制ProductStoreEmailSetting上的BCC"
    end
    attribute :allow_auth_to_negative, :boolean, public?: true
    attribute :min_balance, :decimal, public?: true
    attribute :replenish_threshold, :decimal, public?: true
    attribute :replenish_method_enum_id, :string do
      public? true
      description "补充账户的补充方法。可以是FARP_TOP_OFF或FARP_REPLENISH_LEVEL。默认FARP_TOP_OFF"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboV4.Ofbiz.Product.ProductStore do
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
