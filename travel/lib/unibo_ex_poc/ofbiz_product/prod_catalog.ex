defmodule UniboExPoc.Ofbiz.Product.ProdCatalog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_prod_catalogs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_prod_catalog

    queries do
      get :get_product_prod_catalog, :read
      list :list_product_prod_catalogs, :read
    end

    mutations do
      create :create_product_prod_catalog, :create
      update :update_product_prod_catalog, :update
      destroy :delete_product_prod_catalog, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :prod_catalog_id, :string, public?: true
    attribute :catalog_name, :string, public?: true
    attribute :use_quick_add, :boolean, public?: true
    attribute :style_sheet, :string, public?: true
    attribute :header_logo, :string, public?: true
    attribute :content_path_prefix, :string, public?: true
    attribute :template_path_prefix, :string, public?: true
    attribute :view_allow_perm_reqd, :boolean, public?: true
    attribute :purchase_allow_perm_reqd, :boolean, public?: true
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
