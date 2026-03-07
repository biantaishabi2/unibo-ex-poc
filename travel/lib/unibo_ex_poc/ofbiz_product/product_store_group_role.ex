defmodule UniboExPoc.Ofbiz.Product.ProductStoreGroupRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_group_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_group_role

    queries do
      get :get_product_product_store_group_role, :read
      list :list_product_product_store_group_roles, :read
    end

    mutations do
      create :create_product_product_store_group_role, :create
      update :update_product_product_store_group_role, :update
      destroy :delete_product_product_store_group_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store_group, UniboExPoc.Ofbiz.Product.ProductStoreGroup do
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
