defmodule UniboExPoc.Ofbiz.Order.OrderNotification do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_notifications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_notification

    queries do
      get :get_order_order_notification, :read
      list :list_order_order_notifications, :read
    end

    mutations do
      create :create_order_order_notification, :create
      update :update_order_order_notification, :update
      destroy :delete_order_order_notification, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_notification_id, :string, public?: true
    attribute :email_type, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :notification_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
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
