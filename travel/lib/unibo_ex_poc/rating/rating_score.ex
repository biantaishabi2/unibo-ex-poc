defmodule UniboExPoc.Rating.RatingScore do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "多维度打分明细，随 Rating 一起提交，支持按维度细分评分"
  end

  postgres do
    table "rating_scores"
    repo UniboExPoc.Repo
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
      description "该维度的评分"
    end
    attribute :comment, :string do
      public? true
      description "该维度的评语（可选）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :rating, UniboExPoc.Rating.Rating do
      public? true
      allow_nil? false
    end
    belongs_to :criteria, UniboExPoc.Rating.RatingCriteria do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :submit do
      description "提交维度打分（随 Rating 一起提交）"
      primary? true
      accept [:score, :comment]
      argument :rating_id, :uuid, allow_nil?: false
      argument :criteria_id, :uuid, allow_nil?: false
      change manage_relationship(:rating_id, :rating, type: :append, on_lookup: :relate)
      change manage_relationship(:criteria_id, :criteria, type: :append, on_lookup: :relate)
      validate present(:score)
      validate present(:rating_id)
      validate present(:criteria_id)
      change set_attribute(:id, expr(id))
    end
  end

  validations do
    validate compare(:score, greater_than_or_equal_to: Decimal.new("1"), less_than_or_equal_to: Decimal.new("5"))
  end

  identities do
    identity :unique_criteria_per_rating, [:rating_id, :criteria_id]
  end

end
