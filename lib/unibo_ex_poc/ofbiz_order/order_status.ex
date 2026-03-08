defmodule UniboV4.Ofbiz.Order.OrderStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_statuses"
    repo UniboV4.Repo
  end

  graphql do
    type :order_order_status

    queries do
      get :get_order_order_status, :read
      list :list_order_order_statuss, :read
    end

    mutations do
      create :create_order_order_status, :create
      update :update_order_order_status, :update
      destroy :delete_order_order_status, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_status_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :status_datetime, :utc_datetime, public?: true
    attribute :status_user_login, :string, public?: true
    attribute :change_reason, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboV4.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :order_payment_preference, UniboV4.Ofbiz.Order.OrderPaymentPreference do
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
