defmodule UniboExPoc.Ofbiz.Order.OrderSummaryEntry do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_summary_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_summary_entry

    queries do
      get :get_order_order_summary_entry, :read
      list :list_order_order_summary_entrys, :read
    end

    mutations do
      create :create_order_order_summary_entry, :create
      update :update_order_order_summary_entry, :update
      destroy :delete_order_order_summary_entry, :destroy
    end

  end

  attributes do
    attribute :entry_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :total_quantity, :decimal, public?: true
    attribute :gross_sales, :decimal, public?: true
    attribute :product_cost, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
