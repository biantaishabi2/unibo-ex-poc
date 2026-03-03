defmodule UniboV4.Ecommerce.ProductTemplatePublicCategoryLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_product_template_public_category_links"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_product_template_public_category_link

    queries do
      get :get_ecommerce_product_template_public_category_link, :read
      list :list_ecommerce_product_template_public_category_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :product_template, UniboV4.Ecommerce.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :product_category, UniboV4.Ecommerce.ProductCategory do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
