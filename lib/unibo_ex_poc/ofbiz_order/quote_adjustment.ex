defmodule UniboExPoc.Ofbiz.Order.QuoteAdjustment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "注意：includeInTax 和 includeInShipping 应默认为 true，但当调整为税收或运费调整时应被忽略"
  end

  postgres do
    table "order_quote_adjustments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_quote_adjustment

    queries do
      get :get_order_quote_adjustment, :read
      list :list_order_quote_adjustments, :read
    end

    mutations do
      create :create_order_quote_adjustment, :create
      update :update_order_quote_adjustment, :update
      destroy :delete_order_quote_adjustment, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :quote_adjustment_id, :string, public?: true
    attribute :quote_item_seq_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :description, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :product_promo_id, :string, public?: true
    attribute :product_promo_rule_id, :string, public?: true
    attribute :product_promo_action_seq_id, :string, public?: true
    attribute :product_feature_id, :string, public?: true
    attribute :corresponding_product_id, :string, public?: true
    attribute :source_reference_id, :string, public?: true
    attribute :source_percentage, :decimal, public?: true
    attribute :customer_reference_id, :string, public?: true
    attribute :primary_geo_id, :string, public?: true
    attribute :secondary_geo_id, :string, public?: true
    attribute :exempt_amount, :decimal, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :tax_auth_party_id, :string, public?: true
    attribute :override_gl_account_id, :string, public?: true
    attribute :include_in_tax, :boolean, public?: true
    attribute :include_in_shipping, :boolean, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_adjustment_type, UniboExPoc.Ofbiz.Order.OrderAdjustmentType do
      public? true
      source_attribute :quote_adjustment_type_id
      attribute_type :string
    end
    belongs_to :quote, UniboExPoc.Ofbiz.Order.Quote do
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
