defmodule UniboExPoc.Ofbiz.Product.ReorderGuideline do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_reorder_guidelines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_reorder_guideline

    queries do
      get :get_product_reorder_guideline, :read
      list :list_product_reorder_guidelines, :read
    end

    mutations do
      create :create_product_reorder_guideline, :create
      update :update_product_reorder_guideline, :update
      destroy :delete_product_reorder_guideline, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :reorder_guideline_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :geo_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :reorder_quantity, :decimal, public?: true
    attribute :reorder_level, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
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
