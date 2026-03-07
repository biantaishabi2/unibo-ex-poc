defmodule UniboExPoc.Ofbiz.Product.ProductStoreEmailSetting do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_email_settings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_email_setting

    queries do
      get :get_product_product_store_email_setting, :read
      list :list_product_product_store_email_settings, :read
    end

    mutations do
      create :create_product_product_store_email_setting, :create
      update :update_product_product_store_email_setting, :update
      destroy :delete_product_product_store_email_setting, :destroy
    end

  end

  attributes do
    attribute :product_store_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :email_type, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :body_screen_location, :string do
      public? true
      description "如果为空，默认使用基于emailType的屏幕"
    end
    attribute :xslfo_attach_screen_location, :string do
      public? true
      description "如果指定，则用于生成XSL:FO，该FO通过Apache FOP转换为PDF并附加到电子邮件"
    end
    attribute :from_address, :string, public?: true
    attribute :cc_address, :string, public?: true
    attribute :bcc_address, :string, public?: true
    attribute :subject, :string, public?: true
    attribute :content_type, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
