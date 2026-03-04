# Workflow: rating_criteria_lifecycle — 评价维度维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reorder
#   create --> destroy
#   update --> reorder
#   update --> destroy
#   reorder --> update
#   reorder --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Rating.RatingCriteria do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "rating_criterias"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :weight, :decimal do
      default 1.0
      public? true
    end
    attribute :sort_order, :integer do
      default 0
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :rating_type, UniboV4.Rating.RatingType do
      public? true
    end
    has_many :scores, UniboV4.Rating.RatingScore do
      public? true
      destination_attribute :criteria_id
    end
    has_many :translations, UniboV4.Rating.RatingCriteriaTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :code, :weight, :sort_order, :active]
      argument :rating_type_id, :uuid, allow_nil?: false
      validate present(:name)
      validate present(:code)
      validate present(:rating_type_id)
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
      accept [:name, :description, :weight, :sort_order, :active]
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
    update :reorder do
      accept [:sort_order]
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
    validate compare(:weight, greater_than: 0)
  end

  identities do
    identity :unique_code_per_type, [:rating_type_id, :code]
  end

end
