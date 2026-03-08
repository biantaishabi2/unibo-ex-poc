defmodule UniboV4.Ofbiz.Order.ShoppingList do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_shopping_lists"
    repo UniboV4.Repo
  end

  graphql do
    type :order_shopping_list

    queries do
      get :get_order_shopping_list, :read
      list :list_order_shopping_lists, :read
    end

    mutations do
      create :create_order_shopping_list, :create
      update :update_order_shopping_list, :update
      destroy :delete_order_shopping_list, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shopping_list_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :visitor_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :list_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :is_public, :boolean, public?: true
    attribute :is_active, :boolean, public?: true
    attribute :currency_uom, :string, public?: true
    attribute :shipment_method_type_id, :string, public?: true
    attribute :carrier_party_id, :string, public?: true
    attribute :carrier_role_type_id, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :payment_method_id, :string, public?: true
    attribute :recurrence_info_id, :string, public?: true
    attribute :last_ordered_date, :utc_datetime, public?: true
    attribute :last_admin_modified, :utc_datetime, public?: true
    attribute :product_promo_code_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_shopping_list, UniboV4.Ofbiz.Order.ShoppingList do
      public? true
      attribute_type :string
    end
    has_many :sibling_shopping_list, UniboV4.Ofbiz.Order.ShoppingList do
      public? true
    end
    belongs_to :shopping_list_type, UniboV4.Ofbiz.Order.ShoppingListType do
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
    archive_related [:sibling_shopping_list]
  end

end
