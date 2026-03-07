defmodule UniboExPoc.Ofbiz.Order.CartAbandonedLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_cart_abandoned_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cart_abandoned_line

    queries do
      get :get_order_cart_abandoned_line, :read
      list :list_order_cart_abandoned_lines, :read
    end

    mutations do
      create :create_order_cart_abandoned_line, :create
      update :update_order_cart_abandoned_line, :update
      destroy :delete_order_cart_abandoned_line, :destroy
    end

  end

  attributes do
    attribute :visit_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :cart_abandoned_line_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :product_id, :string, public?: true
    attribute :prod_catalog_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :reserv_start, :utc_datetime, public?: true
    attribute :reserv_length, :decimal, public?: true
    attribute :reserv_persons, :decimal, public?: true
    attribute :unit_price, :decimal, public?: true
    attribute :reserv2nd_pp_perc, :decimal, public?: true
    attribute :reserv_nth_pp_perc, :decimal, public?: true
    attribute :config_id, :string, public?: true
    attribute :total_with_adjustments, :decimal, public?: true
    attribute :was_reserved, :boolean, public?: true
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
