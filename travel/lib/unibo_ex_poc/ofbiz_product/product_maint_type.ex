defmodule UniboExPoc.Ofbiz.Product.ProductMaintType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用于定期和非定期维护；使用ProductMaint跟踪定期维护的详细信息"
  end

  postgres do
    table "product_maint_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_maint_type

    queries do
      get :get_product_product_maint_type, :read
      list :list_product_product_maint_types, :read
    end

    mutations do
      create :create_product_product_maint_type, :create
      update :update_product_product_maint_type, :update
      destroy :delete_product_product_maint_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_maint_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_product_maint_type, UniboExPoc.Ofbiz.Product.ProductMaintType do
      public? true
      source_attribute :parent_type_id
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
