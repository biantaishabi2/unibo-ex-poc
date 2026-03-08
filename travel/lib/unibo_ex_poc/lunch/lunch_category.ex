# Workflow: category_management — 分类管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Lunch.LunchCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "午餐菜品分类"
  end

  postgres do
    table "lunch_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_category

    queries do
      get :get_lunch_lunch_category, :read
      list :list_lunch_lunch_categorys, :read
    end

    mutations do
      create :create_lunch_lunch_category, :create
      update :update_lunch_lunch_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "分类名称"
    end
    attribute :image, :string do
      public? true
      description "分类图片（当产品无图片时作为回退）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :products, UniboExPoc.Lunch.LunchProduct do
      public? true
      destination_attribute :category_id
    end
    has_many :translations, UniboExPoc.Lunch.LunchCategoryTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :image]
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
      accept [:name, :image]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
