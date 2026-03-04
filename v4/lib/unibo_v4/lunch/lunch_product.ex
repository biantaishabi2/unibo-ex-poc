# Workflow: product_management — 菜品管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> toggle_favorite
#   create --> destroy
#   update --> update
#   update --> toggle_favorite
#   update --> destroy
#   toggle_favorite --> toggle_favorite
#   toggle_favorite --> update
#   toggle_favorite --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Lunch.LunchProduct do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_products"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :new_until, :date, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :image, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_new
    # TODO: 不支持的 calculation 表达式 :is_favorite
    # TODO: 不支持的 calculation 表达式 :last_order_date
    # TODO: 不支持的 calculation 表达式 :product_image
  end

  relationships do
    belongs_to :supplier, UniboV4.Lunch.LunchSupplier do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboV4.Lunch.LunchCategory do
      public? true
      allow_nil? false
    end
    many_to_many :favorite_users, UniboV4.Lunch.User do
      public? true
      through UniboV4.Lunch.LunchProductFavoriteUserLink
    end
    has_many :orders, UniboV4.Lunch.LunchOrder do
      public? true
      destination_attribute :product_id
    end
    has_many :translations, UniboV4.Lunch.LunchProductTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :price, :description, :new_until, :image]
      argument :supplier_id, :uuid, allow_nil?: false
      argument :category_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
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
      accept [:name, :price, :description, :new_until, :image]
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
    update :toggle_favorite do
      accept []
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

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
  end

end
