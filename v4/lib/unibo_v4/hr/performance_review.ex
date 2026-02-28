defmodule UniboV4.HR.PerformanceReview do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "performance_reviews"
    repo UniboV4.Repo
  end

  graphql do
    type :performance_review

    queries do
      get :get_performance_review, :read
      list :list_performance_reviews, :read
    end

    mutations do
      create :create_performance_review, :create
      update :submit_performance_review, :submit
      update :complete_performance_review, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :review_period, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :completed]
      default :draft
    end
    attribute :overall_rating, :atom, constraints: [one_of: [:outstanding, :exceeds, :meets, :below, :unsatisfactory]]
    attribute :comments, :string
    attribute :review_date, :date
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
    end
    belongs_to :reviewer, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:review_period, :review_date, :comments]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change relate_actor(:reviewer)
    end
    update :submit do
      accept [:overall_rating, :comments]
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

end
