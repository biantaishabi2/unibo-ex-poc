defmodule UniboExPoc.Ofbiz.Order.ReturnHeader do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_return_headers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_return_header

    queries do
      get :get_order_return_header, :read
      list :list_order_return_headers, :read
    end

    mutations do
      create :create_order_return_header, :create
      update :update_order_return_header, :update
      destroy :delete_order_return_header, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :created_by, :string, public?: true
    attribute :from_party_id, :string, public?: true
    attribute :to_party_id, :string, public?: true
    attribute :payment_method_id, :string, public?: true
    attribute :fin_account_id, :string, public?: true
    attribute :billing_account_id, :string, public?: true
    attribute :entry_date, :utc_datetime, public?: true
    attribute :origin_contact_mech_id, :string, public?: true
    attribute :destination_facility_id, :string, public?: true
    attribute :needs_inventory_receive, :boolean, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :supplier_rma_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_header_type, UniboExPoc.Ofbiz.Order.ReturnHeaderType do
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
