defmodule UniboExPoc.Ofbiz.Product.SubscriptionResource do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_resources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription_resource

    queries do
      get :get_product_subscription_resource, :read
      list :list_product_subscription_resources, :read
    end

    mutations do
      create :create_product_subscription_resource, :create
      update :update_product_subscription_resource, :update
      destroy :delete_product_subscription_resource, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :subscription_resource_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :content_id, :string do
      public? true
      description "此订阅将代表的Content记录的ID（如果适用，请使用）"
    end
    attribute :web_site_id, :string do
      public? true
      description "此订阅将代表的WebSite记录的ID（如果适用，请使用）"
    end
    attribute :service_name_on_expiry, :string do
      public? true
      description "将在订阅过期时运行的服务的名称"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_subscription_resource, UniboExPoc.Ofbiz.Product.SubscriptionResource do
      public? true
      source_attribute :parent_resource_id
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
