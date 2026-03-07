# Workflow: product_template_lifecycle — 产品模板生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   publish --> update
#   publish --> unpublish
#   publish --> discontinue
#   update --> update
#   update --> publish
#   update --> unpublish
#   update --> discontinue
#   unpublish --> publish
#   unpublish --> discontinue
#   discontinue --> reactivate
#   reactivate --> publish
# ```
defmodule UniboExPoc.Ecommerce.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Ecommerce.ProductTemplate.Notifier]

  resource do
    description "产品模板"
  end

  postgres do
    table "ecommerce_product_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_product_template

    queries do
      get :get_ecommerce_product_template, :read
      list :list_ecommerce_product_templates, :read
    end

    mutations do
      create :create_ecommerce_product_template, :create
      update :update_ecommerce_product_template, :update
      update :publish_ecommerce_product_template, :publish
      update :unpublish_ecommerce_product_template, :unpublish
      update :discontinue_ecommerce_product_template, :discontinue
      update :reactivate_ecommerce_product_template, :reactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string do
      allow_nil? false
      public? true
      description "产品编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
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
    attribute :description_ecommerce, :string do
      public? true
      description "电商专用描述（HTML），写入时自动清理空标签"
    end
    attribute :internal_notes, :string, public?: true
    attribute :weight, :decimal, public?: true
    attribute :weight_unit, :string do
      default "kg"
      public? true
    end
    attribute :is_published, :boolean do
      default false
      public? true
      description "是否上架（多站点发布）"
    end
    attribute :website_sequence, :integer do
      default 0
      public? true
      description "商城排序，步进5，支持 top/bottom/up/down 操作"
    end
    attribute :website_size_x, :integer do
      default 1
      public? true
      description "网格布局宽度"
    end
    attribute :website_size_y, :integer do
      default 1
      public? true
      description "网格布局高度"
    end
    attribute :base_unit_count, :decimal do
      public? true
      description "基础计量单位数量（用于\"每kg价格\"展示）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :rating_avg, :decimal, expr(avg(ratings, field: :score, query: [filter: expr(true)]))
    calculate :rating_count, :integer, expr(count(ratings_where_is_published_true, query: [filter: expr(true)]))
    calculate :base_unit_price, :decimal, expr(avg(prices, field: :amount, query: [filter: expr(true)]))
  end

  relationships do
    has_many :variants, UniboExPoc.Ecommerce.ProductVariant do
      public? true
      destination_attribute :template_id
    end
    belongs_to :category, UniboExPoc.Ecommerce.ProductCategory do
      public? true
    end
    has_many :prices, UniboExPoc.Ecommerce.ProductPrice do
      public? true
      destination_attribute :product_id
    end
    belongs_to :website_ribbon, UniboExPoc.Ecommerce.Ribbon do
      public? true
    end
    many_to_many :public_categories, UniboExPoc.Ecommerce.ProductCategory do
      public? true
      through UniboExPoc.Ecommerce.ProductTemplatePublicCategoryLink
    end
    many_to_many :alternative_products, UniboExPoc.Ecommerce.ProductTemplate do
      public? true
      through UniboExPoc.Ecommerce.ProductTemplateAlternativeLink
    end
    many_to_many :accessory_products, UniboExPoc.Ecommerce.ProductTemplate do
      public? true
      through UniboExPoc.Ecommerce.ProductTemplateAccessoryLink
    end
    belongs_to :base_unit, UniboExPoc.Ecommerce.UOM do
      public? true
    end
    has_many :translations, UniboExPoc.Ecommerce.ProductTemplateTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :name, :product_type, :description, :description_ecommerce, :internal_notes, :weight, :weight_unit, :base_unit_count]
      argument :category_id, :uuid
      validate present(:product_code)
      validate present(:name)
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.CreateCall7
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
      accept [:name, :product_type, :status, :description, :description_ecommerce, :internal_notes, :weight, :weight_unit, :is_published, :website_sequence, :website_size_x, :website_size_y, :base_unit_count]
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.UpdateCall7
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
    update :publish do
      description "上架 — 同时设置 is_published=true 和 status=active；必须至少有一个 active 变体"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态的产品可以上架"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:is_published, true)
      change set_attribute(:status, :active)
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.PublishCall7
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
    update :unpublish do
      description "下架 — 设置 is_published=false，status 保持 active"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的产品可以下架或停产"
      change set_attribute(:is_published, false)
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.UnpublishCall7
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
    update :discontinue do
      description "停产"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的产品可以下架或停产"
      change set_attribute(:status, :discontinued)
      change set_attribute(:is_published, false)
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.DiscontinueCall7
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
    update :reactivate do
      description "重新激活已停产产品"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :discontinued do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :discontinued}))
        end
      end
      # message: "只有已停产的产品可以重新激活"
      change set_attribute(:status, :active)
      change UniboExPoc.Ecommerce.Changes.ProductTemplate.ReactivateCall7
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
    identity :unique_product_code, [:product_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
