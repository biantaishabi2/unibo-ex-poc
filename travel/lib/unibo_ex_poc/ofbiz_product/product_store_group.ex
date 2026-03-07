defmodule UniboExPoc.Ofbiz.Product.ProductStoreGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_group

    queries do
      get :get_product_product_store_group, :read
      list :list_product_product_store_groups, :read
    end

    mutations do
      create :create_product_product_store_group, :create
      update :update_product_product_store_group, :update
      destroy :delete_product_product_store_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_store_group_id, :string, public?: true
    attribute :product_store_group_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store_group_type, UniboExPoc.Ofbiz.Product.ProductStoreGroupType do
      public? true
    end
    belongs_to :primary_parent_product_store_group, UniboExPoc.Ofbiz.Product.ProductStoreGroup do
      public? true
      source_attribute :primary_parent_group_id
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
