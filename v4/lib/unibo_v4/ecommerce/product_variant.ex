# Workflow: variant_lifecycle — 产品变体生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> create_dynamic_variant
#   update --> update
#   create_dynamic_variant --> update
# ```
defmodule UniboV4.Ecommerce.ProductVariant do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_product_variants"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :sku, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :attributes_json, :string, public?: true
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
    # TODO: 不支持的 calculation 表达式 :combination_info_price
    # TODO: 不支持的 calculation 表达式 :combination_info_has_discounted_price
    # TODO: 不支持的 calculation 表达式 :combination_info_is_combination_possible
  end

  relationships do
    belongs_to :template, UniboV4.Ecommerce.ProductTemplate do
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

end
