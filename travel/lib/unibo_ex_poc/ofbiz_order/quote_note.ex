defmodule UniboExPoc.Ofbiz.Order.QuoteNote do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_quote_notes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_quote_note

    queries do
      get :get_ofbiz_order_quote_note, :read
      list :list_ofbiz_order_quote_notes, :read
    end

    mutations do
      create :create_ofbiz_order_quote_note, :create
      update :update_ofbiz_order_quote_note, :update
      destroy :delete_ofbiz_order_quote_note, :destroy
    end

  end

  attributes do
    attribute :note_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quote, UniboExPoc.Ofbiz.Order.Quote do
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
