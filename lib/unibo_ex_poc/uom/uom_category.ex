# Workflow: uom_category_maintain_flow — 计量单位分类维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Uom.UomCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Uom,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "计量单位分类，每个分类有且仅有一个参考单位（reference）"
  end

  postgres do
    table "uom_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :uom_uom_category

    queries do
      get :get_uom_uom_category, :read
      list :list_uom_uom_categorys, :read
    end

    mutations do
      create :create_uom_uom_category, :create
      update :update_uom_uom_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "分类名称（如：重量、长度、体积）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :uoms, UniboExPoc.Uom.Uom do
      public? true
      destination_attribute :category_id
    end
    has_many :translations, UniboExPoc.Uom.UomCategoryTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
