defmodule UniboV4.Rating.RatingScore do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rating_scores"
    repo UniboV4.Repo
  end

  graphql do
    type :rating_rating_score

    queries do
      get :get_rating_rating_score, :read
      list :list_rating_rating_scores, :read
    end

    mutations do
      create :create_submit_rating_rating_score, :submit
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :score, :decimal do
      allow_nil? false
      public? true
    end
    attribute :comment, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :rating, UniboV4.Rating.Rating do
      public? true
      allow_nil? false
    end
    belongs_to :criteria, UniboV4.Rating.RatingCriteria do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :submit do
      primary? true
      accept [:score, :comment]
      argument :rating_id, :uuid, allow_nil?: false
      argument :criteria_id, :uuid, allow_nil?: false
      change manage_relationship(:rating_id, :rating, type: :append, on_lookup: :relate)
      change manage_relationship(:criteria_id, :criteria, type: :append, on_lookup: :relate)
      validate present(:score)
      validate present(:rating_id)
      validate present(:criteria_id)
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
    validate compare(:score, greater_than_or_equal_to: 1.0, less_than_or_equal_to: 5.0)
  end

  identities do
    identity :unique_criteria_per_rating, [:rating_id, :criteria_id]
  end

end
