defmodule UniboV4.Ofbiz.Order.CustRequestItemNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_item_notes"
    repo UniboV4.Repo
  end

  graphql do
    type :order_cust_request_item_note

    queries do
      get :get_order_cust_request_item_note, :read
      list :list_order_cust_request_item_notes, :read
    end

    mutations do
      create :create_order_cust_request_item_note, :create
      update :update_order_cust_request_item_note, :update
      destroy :delete_order_cust_request_item_note, :destroy
    end

  end

  attributes do
    attribute :cust_request_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :cust_request_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :note_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
