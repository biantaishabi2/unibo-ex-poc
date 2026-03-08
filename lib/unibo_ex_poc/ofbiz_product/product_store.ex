defmodule UniboV4.Ofbiz.Product.ProductStore do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_stores"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_store

    queries do
      get :get_product_product_store, :read
      list :list_product_product_stores, :read
    end

    mutations do
      create :create_product_product_store, :create
      update :update_product_product_store, :update
      destroy :delete_product_product_store, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_store_id, :string, public?: true
    attribute :store_name, :string, public?: true
    attribute :company_name, :string, public?: true
    attribute :title, :string, public?: true
    attribute :subtitle, :string, public?: true
    attribute :pay_to_party_id, :string do
      public? true
      description "注意这对应于GL交易将过账的organizationPartyId"
    end
    attribute :days_to_cancel_non_pay, :integer, public?: true
    attribute :manual_auth_is_capture, :boolean, public?: true
    attribute :prorate_shipping, :boolean, public?: true
    attribute :prorate_taxes, :boolean, public?: true
    attribute :view_cart_on_add, :boolean, public?: true
    attribute :auto_save_cart, :boolean, public?: true
    attribute :auto_approve_reviews, :boolean, public?: true
    attribute :is_demo_store, :boolean, public?: true
    attribute :is_immediately_fulfilled, :boolean do
      public? true
      description "如果立即履行（对于实体店等）：不发送电子邮件通知，不保留库存，如果在服务器上找不到库存信息，则不立即发放库存"
    end
    attribute :one_inventory_facility, :boolean, public?: true
    attribute :check_inventory, :boolean, public?: true
    attribute :reserve_inventory, :boolean, public?: true
    attribute :reserve_order_enum_id, :string, public?: true
    attribute :require_inventory, :boolean, public?: true
    attribute :balance_res_on_order_creation, :boolean do
      public? true
      description "如果设置为Y，当创建包含缺货项目的新销售订单时，设施/产品上的预留将根据shipBeforeDate字段给定的优先级重新分配"
    end
    attribute :requirement_method_enum_id, :string, public?: true
    attribute :order_number_prefix, :string, public?: true
    attribute :default_locale_string, :string, public?: true
    attribute :default_currency_uom_id, :string, public?: true
    attribute :default_time_zone_string, :string, public?: true
    attribute :default_sales_channel_enum_id, :string, public?: true
    attribute :allow_password, :boolean, public?: true
    attribute :default_password, :string, public?: true
    attribute :explode_order_items, :boolean, public?: true
    attribute :check_gc_balance, :boolean, public?: true
    attribute :retry_failed_auths, :boolean, public?: true
    attribute :header_approved_status, :string, public?: true
    attribute :item_approved_status, :string, public?: true
    attribute :digital_item_approved_status, :string, public?: true
    attribute :header_declined_status, :string, public?: true
    attribute :item_declined_status, :string, public?: true
    attribute :header_cancel_status, :string, public?: true
    attribute :item_cancel_status, :string, public?: true
    attribute :auth_declined_message, :string, public?: true
    attribute :auth_fraud_message, :string, public?: true
    attribute :auth_error_message, :string, public?: true
    attribute :visual_theme_id, :string, public?: true
    attribute :store_credit_account_enum_id, :string do
      public? true
      description "指定用于退款的商店积分账户的类型（计费账户或财务账户）。默认为财务账户。此字段可由ReturnHeader.billingAccountId或ReturnHeader.finAccountId覆盖（以指定者为准），但如果仅明确指定finAccountId，则系统将首先尝试查找任何具有负数金额的计费账户。如果找到，则将金额计入此计费账户，否则将金额计入用户的财务账户"
    end
    attribute :use_primary_email_username, :boolean, public?: true
    attribute :require_customer_role, :boolean, public?: true
    attribute :auto_invoice_digital_items, :boolean do
      public? true
      description "默认为Y。订单下达时发票数字产品，而不是等待完成订单项（尽管装运/履行）"
    end
    attribute :req_ship_addr_for_dig_items, :boolean do
      public? true
      description "默认为Y。数字产品需要运输地址吗？注意：仅当购物车中只有数字商品时，此选项才有效"
    end
    attribute :show_checkout_gift_options, :boolean, public?: true
    attribute :select_payment_type_per_item, :boolean, public?: true
    attribute :show_prices_with_vat_tax, :boolean, public?: true
    attribute :show_tax_is_exempt, :boolean do
      public? true
      description "默认为Y；如果设置为N，不显示PartyTaxAuthInfo的isExempt复选框，始终强制为N"
    end
    attribute :vat_tax_auth_geo_id, :string, public?: true
    attribute :vat_tax_auth_party_id, :string, public?: true
    attribute :enable_auto_suggestion_list, :boolean do
      public? true
      description "自动建议列表是一个特殊的ShoppingList，addSuggestionsToShoppingList服务将维护它以进行订购物品的交叉销售"
    end
    attribute :enable_dig_prod_upload, :boolean, public?: true
    attribute :prod_search_exclude_variants, :boolean do
      public? true
      description "默认为Y；如果设置为Y，将对商店的所有产品搜索添加isVariant!=Y的额外约束"
    end
    attribute :dig_prod_upload_category_id, :string, public?: true
    attribute :auto_order_cc_try_exp, :boolean do
      public? true
      description "对于自动订单，是否尝试其他信用卡过期日期（如果日期错误或类型未知的一般故障）？"
    end
    attribute :auto_order_cc_try_other_cards, :boolean do
      public? true
      description "对于自动订单，是否为客户尝试其他信用卡？"
    end
    attribute :auto_order_cc_try_later_nsf, :boolean do
      public? true
      description "对于自动订单，如果信用卡因NSF（资金不足）失败，是否稍后重试？"
    end
    attribute :auto_order_cc_try_later_max, :integer do
      public? true
      description "对于自动订单，如果信用卡因NSF失败，应重试多少次？"
    end
    attribute :store_credit_valid_days, :integer do
      public? true
      description "商店积分有效天数。空值表示无过期时间"
    end
    attribute :auto_approve_invoice, :boolean do
      public? true
      description "如果为Y或空，从订单创建的销售发票将标记为就绪"
    end
    attribute :auto_approve_order, :boolean do
      public? true
      description "如果为N，付款授权时订单不会自动批准"
    end
    attribute :ship_if_capture_fails, :boolean do
      public? true
      description "如果为N，当信用卡捕获失败时，captureOrderPayments将导致服务错误"
    end
    attribute :set_owner_upon_issuance, :boolean do
      public? true
      description "如果为Y或空，在发放时设置库存品所有者"
    end
    attribute :req_return_inventory_receive, :boolean do
      public? true
      description "默认为N。这是ReturnHeader.needsInventoryReceive字段的默认值。如果设置为Y，退货在被接受时将自动进入已接收状态，而不是等待实际收到退货"
    end
    attribute :add_to_cart_remove_incompat, :boolean do
      public? true
      description "默认为N。如果为Y，则在添加到购物车时，移除购物车中所有具有与产品相关或来自产品的ProductAssoc记录且类型为PRODUCT_INCOMPATABLE的产品"
    end
    attribute :add_to_cart_replace_upsell, :boolean do
      public? true
      description "默认为N。如果为Y，则在添加到购物车时，移除购物车中所有具有来自产品的ProductAssoc记录且类型为PRODUCT_UPGRADE的产品"
    end
    attribute :split_pay_pref_per_shp_grp, :boolean do
      public? true
      description "默认为N。如果为Y，则在存储订单前，OrderPaymentPreference记录将被拆分，每个OrderItemShipGroup一条记录。"
    end
    attribute :managed_by_lot, :boolean do
      public? true
      description "如果为Y，准备者在制作拣货单时可以通过此lotId选择InventoryItem"
    end
    attribute :show_out_of_stock_products, :boolean do
      public? true
      description "默认为Y。如果为N，则缺货产品将不显示在网站上"
    end
    attribute :order_decimal_quantity, :boolean do
      public? true
      description "用于指示是否可以为此产品商店订购小数数量。默认值为Y"
    end
    attribute :allow_comment, :boolean do
      public? true
      description "允许按商店为订单项添加评论"
    end
    attribute :allocate_inventory, :boolean do
      public? true
      description "默认为N。如果为Y，则将为产品创建分配计划"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :primary_product_store_group, UniboV4.Ofbiz.Product.ProductStoreGroup do
      public? true
      source_attribute :primary_store_group_id
    end
    belongs_to :facility, UniboV4.Ofbiz.Product.Facility do
      public? true
      source_attribute :inventory_facility_id
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
