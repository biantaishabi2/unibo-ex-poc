defmodule UniboV4.Ofbiz.HumanRes.PerfReviewItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "human_res_perf_review_items"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_perf_review_item

    queries do
      get :get_human_res_perf_review_item, :read
      list :list_human_res_perf_review_items, :read
    end

    mutations do
      create :create_human_res_perf_review_item, :create
      update :update_human_res_perf_review_item, :update
      destroy :delete_human_res_perf_review_item, :destroy
    end

  end

  attributes do
    attribute :employee_role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :perf_review_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :perf_review_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :employee_party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :perf_rating_type, UniboV4.Ofbiz.HumanRes.PerfRatingType do
      public? true
      attribute_type :string
    end
    belongs_to :perf_review_item_type, UniboV4.Ofbiz.HumanRes.PerfReviewItemType do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
