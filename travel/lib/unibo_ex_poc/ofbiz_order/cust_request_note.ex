defmodule UniboExPoc.Ofbiz.Order.CustRequestNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_notes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request_note

    queries do
      get :get_order_cust_request_note, :read
      list :list_order_cust_request_notes, :read
    end

    mutations do
      create :create_order_cust_request_note, :create
      update :update_order_cust_request_note, :update
      destroy :delete_order_cust_request_note, :destroy
    end

  end

  attributes do
    attribute :note_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request, UniboExPoc.Ofbiz.Order.CustRequest do
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
