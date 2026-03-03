# Workflow: rating_review_flow — 评价提交与审核流程
# ```mermaid
# stateDiagram-v2
#   [*] --> submit
#   submit --> update
#   submit --> approve
#   submit --> reject
#   update --> approve
#   update --> reject
#   approve --> flag
#   reject --> [*]
#   flag --> [*]
# ```
defmodule UniboV4.Rating.Rating.Rating do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Rating.Rating.Rating.Notifier]

  postgres do
    table "rating_ratings"
    repo UniboV4.Repo
  end

  graphql do
    type :rating_rating

    queries do
      get :get_rating_rating, :read
      list :list_rating_ratings, :read
    end

    mutations do
      create :create_submit_rating_rating, :submit
      update :update_rating_rating, :update
      update :approve_rating_rating, :approve
      update :reject_rating_rating, :reject
      update :flag_rating_rating, :flag
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :resource_type, :string do
      allow_nil? false
      public? true
    end
    attribute :resource_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :score, :decimal do
      allow_nil? false
      public? true
    end
    attribute :comment, :string, public?: true
    attribute :reviewer_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :is_anonymous, :boolean do
      default false
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending_approval, :published, :rejected, :flagged]
      default :pending_approval
      public? true
    end
    attribute :flag_reason, :string, public?: true
    attribute :rejection_reason, :string, public?: true
    attribute :submitted_at, :utc_datetime, public?: true
    attribute :published_at, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :rating_type, UniboV4.Rating.Rating.RatingType do
      public? true
    end
    has_many :scores, UniboV4.Rating.Rating.RatingScore do
      public? true
      destination_attribute :rating_id
    end
  end

  actions do
    defaults [:read]
    create :submit do
      primary? true
      accept [:resource_type, :resource_id, :score, :comment, :reviewer_id, :is_anonymous]
      argument :rating_type_id, :uuid
      validate present(:resource_type)
      validate present(:resource_id)
      validate present(:score)
      validate present(:reviewer_id)
      change set_attribute(:status, :pending_approval)
      # TODO: 跨实体聚合表达式暂不支持
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
      accept [:score, :comment, :is_anonymous]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
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
    update :approve do
      accept []
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      change set_attribute(:status, :published)
      # TODO: 跨实体聚合表达式暂不支持
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
    update :reject do
      accept [:rejection_reason]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      # skipped: validate present :rejection_reason (incompatible with bulk update atomic path)
      change set_attribute(:status, :rejected)
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
    update :flag do
      accept [:flag_reason]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      # skipped: validate present :flag_reason (incompatible with bulk update atomic path)
      change set_attribute(:status, :flagged)
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
    validate compare(:score, greater_than_or_equal_to: 1.0, less_than_or_equal_to: 5.0)
  end

  identities do
    identity :unique_reviewer_per_resource, [:reviewer_id, :resource_type, :resource_id]
  end

end
