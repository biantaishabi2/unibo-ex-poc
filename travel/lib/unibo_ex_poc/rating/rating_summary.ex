defmodule UniboExPoc.Rating.RatingSummary do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Rating.RatingSummary.Notifier]

  resource do
    description "评价汇总统计（某对象的平均分、评价数、各星级分布），只读聚合实体"
  end

  postgres do
    table "rating_summaries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rating_rating_summary

    queries do
      get :get_rating_rating_summary, :read
      list :list_rating_rating_summarys, :read
    end

    mutations do
      update :recalculate_rating_rating_summary, :recalculate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :resource_type, :string do
      allow_nil? false
      public? true
      description "被评价对象类型（与 Rating.resource_type 对齐，开放字符串）"
    end
    attribute :resource_id, :uuid do
      allow_nil? false
      public? true
      description "被评价对象ID"
    end
    attribute :average_score, :decimal do
      default 0.0
      public? true
      description "平均评分"
    end
    attribute :total_count, :integer do
      default 0
      public? true
      description "评价总数（仅统计 published 状态）"
    end
    attribute :star_1_count, :integer do
      default 0
      public? true
      description "1星评价数"
    end
    attribute :star_2_count, :integer do
      default 0
      public? true
      description "2星评价数"
    end
    attribute :star_3_count, :integer do
      default 0
      public? true
      description "3星评价数"
    end
    attribute :star_4_count, :integer do
      default 0
      public? true
      description "4星评价数"
    end
    attribute :star_5_count, :integer do
      default 0
      public? true
      description "5星评价数"
    end
    attribute :last_rating_at, :utc_datetime do
      public? true
      description "最近一次评价时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :satisfaction_rate, :decimal, expr(compute_satisfaction_rate(star_4_count, star_5_count, total_count))
  end

  actions do
    defaults [:read]
    update :recalculate do
      description "重新计算汇总数据（由 Rating approve 后自动触发）"
      primary? true
      accept [:average_score, :total_count, :star_1_count, :star_2_count, :star_3_count, :star_4_count, :star_5_count, :last_rating_at]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_resource, [:resource_type, :resource_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
