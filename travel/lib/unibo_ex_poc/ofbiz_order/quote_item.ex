defmodule UniboExPoc.Ofbiz.Order.QuoteItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_quote_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_quote_item

    queries do
      get :get_order_quote_item, :read
      list :list_order_quote_items, :read
    end

    mutations do
      create :create_order_quote_item, :create
      update :update_order_quote_item, :update
      destroy :delete_order_quote_item, :destroy
    end

  end

  attributes do
    attribute :quote_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quote_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string, public?: true
    attribute :product_feature_id, :string, public?: true
    attribute :deliverable_type_id, :string, public?: true
    attribute :skill_type_id, :string, public?: true
    attribute :uom_id, :string, public?: true
    attribute :work_effort_id, :string, public?: true
    attribute :cust_request_item_seq_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :selected_amount, :decimal, public?: true
    attribute :quote_unit_price, :decimal, public?: true
    attribute :reserv_start, :utc_datetime, public?: true
    attribute :reserv_length, :decimal, public?: true
    attribute :reserv_persons, :decimal, public?: true
    attribute :config_id, :string, public?: true
    attribute :estimated_delivery_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :is_promo, :boolean, public?: true
    attribute :lead_time_days, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quote, UniboExPoc.Ofbiz.Order.Quote do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :cust_request, UniboExPoc.Ofbiz.Order.CustRequest do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
