defmodule UniboExPoc.Ofbiz.Order.CustRequest do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request

    queries do
      get :get_order_cust_request, :read
      list :list_order_cust_requests, :read
    end

    mutations do
      create :create_order_cust_request, :create
      update :update_order_cust_request, :update
      destroy :delete_order_cust_request, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :cust_request_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :from_party_id, :string, public?: true
    attribute :priority, :integer, public?: true
    attribute :cust_request_date, :utc_datetime do
      public? true
      description "当客户（或其他人）提交请求时，可能在OFBiz之外通过邮件、电子邮件等方式提交的时间"
    end
    attribute :response_required_date, :utc_datetime do
      public? true
      description "需要响应的截止时间"
    end
    attribute :cust_request_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :maximum_amount_uom_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :sales_channel_enum_id, :string, public?: true
    attribute :fulfill_contact_mech_id, :string do
      public? true
      description "支持客户请求位置的字段 - 即产品文献发送到地址、在位置处的服务呼叫等"
    end
    attribute :currency_uom_id, :string, public?: true
    attribute :open_date_time, :utc_datetime do
      public? true
      description "可以通过客户请求日期和openDateTime来查看客户服务人员的效率"
    end
    attribute :closed_date_time, :utc_datetime do
      public? true
      description "在某些客户响应系统中，如果客户对解决方案不满意，openDateTime和closedDateTime可能发生多次"
    end
    attribute :internal_comment, :string, public?: true
    attribute :reason, :string, public?: true
    attribute :created_date, :utc_datetime do
      public? true
      description "当数据实际存储在系统中时"
    end
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime do
      public? true
      description "显示上次执行的操作时间，以查看解决请求的步骤是否及时进行"
    end
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request_type, UniboExPoc.Ofbiz.Order.CustRequestType do
      public? true
      attribute_type :string
    end
    belongs_to :cust_request_category, UniboExPoc.Ofbiz.Order.CustRequestCategory do
      public? true
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
