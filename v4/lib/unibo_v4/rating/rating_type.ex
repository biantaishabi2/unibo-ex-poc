# Workflow: rating_type_lifecycle — 评价类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Rating.RatingType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rating_types"
    repo UniboV4.Repo
  end

  graphql do
    type :rating_rating_type

    queries do
      get :get_rating_rating_type, :read
      list :list_rating_rating_types, :read
    end

    mutations do
      create :create_rating_rating_type, :create
      update :update_rating_rating_type, :update
      destroy :delete_rating_rating_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :applicable_resource_types, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :ratings, UniboV4.Rating.Rating do
      public? true
      destination_attribute :rating_type_id
    end
    has_many :criteria, UniboV4.Rating.RatingCriteria do
      public? true
      destination_attribute :rating_type_id
    end
    has_many :translations, UniboV4.Rating.RatingTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:code, :name, :description, :applicable_resource_types, :active]
      validate present(:code)
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
      accept [:name, :description, :applicable_resource_types, :active]
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
    identity :unique_code, [:code]
  end

end
