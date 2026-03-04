# Workflow: category_lifecycle — 产品分类管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.ProductCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_product_categories"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :category_code, :string do
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

  relationships do
    belongs_to :parent, UniboV4.Ecommerce.ProductCategory do
      public? true
    end
    has_many :products, UniboV4.Ecommerce.ProductTemplate do
      public? true
      destination_attribute :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:category_code, :name, :description]
      argument :parent_id, :uuid
      validate present(:category_code)
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_category_code, [:category_code]
  end

end
