defmodule UniboV4.Ecommerce.ProductTemplateAccessoryLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_product_template_accessory_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :product_template, UniboV4.Ecommerce.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :accessory_product, UniboV4.Ecommerce.ProductTemplate do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
