defmodule UniboExPoc.Ofbiz.Order.Quote do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_quotes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_quote

    queries do
      get :get_ofbiz_order_quote, :read
      list :list_ofbiz_order_quotes, :read
    end

    mutations do
      create :create_ofbiz_order_quote, :create
      update :update_ofbiz_order_quote, :update
      destroy :delete_ofbiz_order_quote, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :quote_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :issue_date, :utc_datetime, public?: true
    attribute :status_id, :string, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :sales_channel_enum_id, :string, public?: true
    attribute :valid_from_date, :utc_datetime, public?: true
    attribute :valid_thru_date, :utc_datetime, public?: true
    attribute :quote_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quote_type, UniboExPoc.Ofbiz.Order.QuoteType do
      public? true
      attribute_type :string
    end
    has_many :quote_note_view, UniboExPoc.Ofbiz.Order.QuoteNote do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:quote_note_view]
  end

end
