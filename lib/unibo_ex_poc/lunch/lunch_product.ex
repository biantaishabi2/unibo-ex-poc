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
defmodule UniboExPoc.Lunch.LunchProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "午餐菜品，包含价格、分类、新品标记和收藏功能"
  end

  postgres do
    table "lunch_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_product

    queries do
      get :get_lunch_lunch_product, :read
      list :list_lunch_lunch_products, :read
    end

    mutations do
      create :create_lunch_lunch_product, :create
      update :update_lunch_lunch_product, :update
      update :toggle_favorite_lunch_lunch_product, :toggle_favorite
      destroy :delete_lunch_lunch_product, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "菜品名称"
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
      description "单价"
    end
    attribute :description, :string do
      public? true
      description "菜品描述"
    end
    attribute :new_until, :date do
      public? true
      description "标记为\"新品\"的截止日期"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :image, :string do
      public? true
      description "菜品图片"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_new, :boolean, expr(new_until >= today())
    calculate :is_favorite, :boolean, {UniboExPoc.Lunch.Calculations.LunchProduct.IsFavorite, []}
    calculate :last_order_date, :date, {UniboExPoc.Lunch.Calculations.LunchProduct.LastOrderDate, []}
    calculate :product_image, :string, {UniboExPoc.Lunch.Calculations.LunchProduct.ProductImage, []}
  end

  relationships do
    belongs_to :supplier, UniboExPoc.Lunch.LunchSupplier do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboExPoc.Lunch.LunchCategory do
      public? true
      allow_nil? false
    end
    many_to_many :favorite_users, UniboExPoc.Lunch.Party do
      public? true
      through UniboExPoc.Lunch.LunchProductFavoriteUserLink
      destination_attribute_on_join_resource :user_party_id
    end
    has_many :orders, UniboExPoc.Lunch.LunchOrder do
      public? true
      destination_attribute :product_id
    end
    has_many :translations, UniboExPoc.Lunch.LunchProductTranslation, public?: true
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :price, :description, :new_until, :image]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :toggle_favorite do
      description "切换当前用户的收藏状态"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:orders]
  end

end
