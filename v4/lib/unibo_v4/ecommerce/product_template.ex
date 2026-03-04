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
defmodule UniboV4.Ecommerce.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Ecommerce.ProductTemplate.Notifier]

  postgres do
    table "ecommerce_product_templates"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string do
      allow_nil? false
      public? true
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
    attribute :description_ecommerce, :string, public?: true
    attribute :internal_notes, :string, public?: true
    attribute :weight, :decimal, public?: true
    attribute :weight_unit, :string do
      default "kg"
      public? true
    end
    attribute :is_published, :boolean do
      default false
      public? true
    end
    attribute :website_sequence, :integer do
      default 0
      public? true
    end
    attribute :website_size_x, :integer do
      default 1
      public? true
    end
    attribute :website_size_y, :integer do
      default 1
      public? true
    end
    attribute :base_unit_count, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :rating_avg
    calculate :rating_count, :integer, expr(count(ratings_where_is_published_true, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :base_unit_price
  end

  relationships do
    has_many :variants, UniboV4.Ecommerce.ProductVariant do
      public? true
      destination_attribute :template_id
    end
    belongs_to :category, UniboV4.Ecommerce.ProductCategory do
      public? true
    end
    has_many :prices, UniboV4.Ecommerce.ProductPrice do
      public? true
      destination_attribute :product_id
    end
    belongs_to :website_ribbon, UniboV4.Ecommerce.Ribbon do
      public? true
    end
    many_to_many :public_categories, UniboV4.Ecommerce.ProductCategory do
      public? true
      through UniboV4.Ecommerce.ProductTemplatePublicCategoryLink
    end
    many_to_many :alternative_products, UniboV4.Ecommerce.ProductTemplate do
      public? true
      through UniboV4.Ecommerce.ProductTemplateAlternativeLink
      source_attribute_on_join_resource :alternative_product_id
      destination_attribute_on_join_resource :alternative_product_id
    end
    many_to_many :accessory_products, UniboV4.Ecommerce.ProductTemplate do
      public? true
      through UniboV4.Ecommerce.ProductTemplateAccessoryLink
      source_attribute_on_join_resource :accessory_product_id
      destination_attribute_on_join_resource :accessory_product_id
    end
    belongs_to :base_unit, UniboV4.Ecommerce.UOM do
      public? true
    end
    has_many :translations, UniboV4.Ecommerce.ProductTemplateTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :name, :product_type, :description, :description_ecommerce, :internal_notes, :weight, :weight_unit, :base_unit_count]
      argument :category_id, :uuid
      validate present(:product_code)
      validate present(:name)
      # TODO: 不支持的 change effect sanitize_html
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
      # TODO: 不支持的 change effect sanitize_html
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:is_published, true)
      change set_attribute(:status, :active)
      # TODO: 不支持的 change effect sanitize_html
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
      # TODO: 不支持的 change effect sanitize_html
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
      # TODO: 不支持的 change effect sanitize_html
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
      # TODO: 不支持的 change effect sanitize_html
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

end
