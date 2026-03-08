defmodule UniboV4.Ofbiz.Product.QuantityBreak do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_quantity_breaks"
    repo UniboV4.Repo
  end

  graphql do
    type :product_quantity_break

    queries do
      get :get_product_quantity_break, :read
      list :list_product_quantity_breaks, :read
    end

    mutations do
      create :create_product_quantity_break, :create
      update :update_product_quantity_break, :update
      destroy :delete_product_quantity_break, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity_break_id, :string, public?: true
    attribute :from_quantity, :decimal, public?: true
    attribute :thru_quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quantity_break_type, UniboV4.Ofbiz.Product.QuantityBreakType do
      public? true
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
