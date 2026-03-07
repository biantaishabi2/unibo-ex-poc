defmodule UniboExPoc.Ofbiz.Product.ProductStoreGroupMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_group_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_group_member

    queries do
      get :get_product_product_store_group_member, :read
      list :list_product_product_store_group_members, :read
    end

    mutations do
      create :create_product_product_store_group_member, :create
      update :update_product_product_store_group_member, :update
      destroy :delete_product_product_store_group_member, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
    belongs_to :product_store_group, UniboExPoc.Ofbiz.Product.ProductStoreGroup do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
