# Workflow: variant_lifecycle — 产品变体生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> create_dynamic_variant
#   update --> update
#   create_dynamic_variant --> update
# ```
defmodule UniboExPoc.Ecommerce.ProductVariant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "产品变体"
  end

  postgres do
    table "ecommerce_product_variants"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_product_variant

    queries do
      get :get_ecommerce_product_variant, :read
      list :list_ecommerce_product_variants, :read
    end

    mutations do
      create :create_create_ecommerce_product_variant, :create
      create :create_create_dynamic_variant_ecommerce_product_variant, :create_dynamic_variant
      update :update_ecommerce_product_variant, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sku, :string do
      allow_nil? false
      public? true
      description "SKU"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :attributes_json, :string do
      public? true
      description "变体属性（JSON，如颜色/尺码）"
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :stock_quantity, :integer do
      default 0
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :combination_info_price, :decimal, expr(price)
    calculate :combination_info_has_discounted_price, :boolean, expr(list_price > pricelist_price)
    calculate :combination_info_is_combination_possible, :boolean, expr(all attributes valid and (variant exists or can_create))
  end

  relationships do
    belongs_to :template, UniboExPoc.Ecommerce.ProductTemplate do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:sku, :name, :attributes_json, :price, :stock_quantity]
      argument :template_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      validate present(:sku)
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
      accept [:name, :attributes_json, :price, :stock_quantity, :is_active]
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
    create :create_dynamic_variant do
      description "动态变体创建 — template 配置为 dynamic 模式时，根据用户选择的属性组合动态创建"
      accept [:attributes_json, :price]
      argument :template_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      validate present(:sku)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_sku, [:sku]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
