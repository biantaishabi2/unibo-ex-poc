defmodule UniboExPoc.Ofbiz.Order.OrderProductPromoCode do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_product_promo_codes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_product_promo_code

    queries do
      get :get_order_order_product_promo_code, :read
      list :list_order_order_product_promo_codes, :read
    end

    mutations do
      create :create_order_order_product_promo_code, :create
      update :update_order_order_product_promo_code, :update
      destroy :delete_order_order_product_promo_code, :destroy
    end

  end

  attributes do
    attribute :product_promo_code_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
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
