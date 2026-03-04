# Workflow: uom_category_maintain_flow — 计量单位分类维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Uom.UomCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Uom,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "uom_categories"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :uoms, UniboV4.Uom.Uom do
      public? true
      destination_attribute :category_id
    end
    has_many :translations, UniboV4.Uom.UomCategoryTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name]
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
      accept [:name]
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

end
