defmodule UniboV4.Ecommerce.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "product_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :product_template

    queries do
      get :get_product_template, :read
      list :list_product_templates, :read
    end

    mutations do
      create :create_product_template, :create
      update :update_product_template, :update
      update :publish_product_template, :publish
      update :unpublish_product_template, :unpublish
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :product_type, :atom do
      constraints one_of: [:goods, :service, :consumable]
      default :goods
        public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :discontinued]
      default :draft
        public? true
    end
    attribute :description, :string, public?: true
    attribute :internal_notes, :string, public?: true
    attribute :weight, :decimal, public?: true
    attribute :weight_unit, :string, default: "kg", public?: true
    attribute :is_published, :boolean, default: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :variants, UniboV4.Ecommerce.ProductVariant
    belongs_to :category, UniboV4.Ecommerce.ProductCategory, public?: true
    has_many :prices, UniboV4.Ecommerce.ProductPrice
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :name, :product_type, :description, :internal_notes, :weight, :weight_unit]
      argument :category_id, :uuid
      validate present(:product_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :product_type, :status, :description, :internal_notes, :weight, :weight_unit, :is_published]
    end
    update :publish do
      accept []
      change set_attribute(:is_published, :true)
      change set_attribute(:status, :active)
    end
    update :unpublish do
      accept []
      change set_attribute(:is_published, :false)
    end
  end

  identities do
    identity :unique_product_code, [:product_code]
  end

end
