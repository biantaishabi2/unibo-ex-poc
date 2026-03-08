# Workflow: catalog_lifecycle — 产品目录管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.Catalog do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "产品目录"
  end

  postgres do
    table "ecommerce_catalogs"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_catalog

    queries do
      get :get_ecommerce_catalog, :read
      list :list_ecommerce_catalogs, :read
    end

    mutations do
      create :create_ecommerce_catalog, :create
      update :update_ecommerce_catalog, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :catalog_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:catalog_code, :name, :description]
      validate present(:catalog_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_catalog_code, [:catalog_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
