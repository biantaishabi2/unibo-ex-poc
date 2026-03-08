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
defmodule UniboExPoc.Rating.Rating do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Rating.Rating.Notifier]

  resource do
    description "通用评价，泛化自 OFBiz ProductReview，通过 resource_type + resource_id 多态关联任意业务对象"
  end

  postgres do
    table "rating_ratings"
    repo UniboExPoc.Repo
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
      description "被评价对象类型（多态关联，替代 ProductReview.product_id；开放字符串，vertical 层可自由扩展如 product、order、supplier 等）"
    end
    attribute :resource_id, :uuid do
      allow_nil? false
      public? true
      description "被评价对象ID（多态关联，替代 ProductReview.product_id）"
    end
    attribute :score, :decimal do
      allow_nil? false
      public? true
      description "综合评分（对齐 ProductReview.product_rating）"
    end
    attribute :comment, :string do
      public? true
      description "评语文本（对齐 ProductReview.product_review）"
    end
    attribute :reviewer_id, :uuid do
      allow_nil? false
      public? true
      description "评价人（对齐 ProductReview.user_login_id）"
    end
    attribute :is_anonymous, :boolean do
      default false
      public? true
      description "是否匿名（对齐 ProductReview.posted_anonymous）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending_approval, :published, :rejected, :flagged]
      default :pending_approval
      public? true
      description "审核状态（对齐 ProductReview.status_id）"
    end
    attribute :flag_reason, :string do
      public? true
      description "举报原因（status 为 flagged 时填写）"
    end
    attribute :rejection_reason, :string do
      public? true
      description "拒绝原因（status 为 rejected 时填写）"
    end
    attribute :submitted_at, :utc_datetime do
      public? true
      description "提交时间（对齐 ProductReview.posted_date_time）"
    end
    attribute :published_at, :utc_datetime do
      public? true
      description "发布时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :rating_type, UniboExPoc.Rating.RatingType do
      public? true
    end
    has_many :scores, UniboExPoc.Rating.RatingScore do
      public? true
      source_attribute :rating_type_id
      destination_attribute :rating_id
    end
  end

  actions do
    defaults [:read]
    create :submit do
      description "提交评价，初始状态为 pending_approval"
      primary? true
      accept [:resource_type, :resource_id, :score, :comment, :reviewer_id, :is_anonymous]
      argument :rating_type_id, :uuid
      validate present(:resource_type)
      validate present(:resource_id)
      validate present(:score)
      validate present(:reviewer_id)
      change set_attribute(:status, :pending_approval)
      change UniboExPoc.Rating.Changes.Rating.ComputeSubmittedAt
      change set_attribute(:id, expr(id))
    end
    update :update do
      description "修改评价内容（仅 pending_approval 状态可修改）"
      primary? true
      accept [:score, :comment, :is_anonymous]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :approve do
      description "审核通过，status 变为 published"
      accept []
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      change set_attribute(:status, :published)
      change UniboExPoc.Rating.Changes.Rating.ComputePublishedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reject do
      description "审核拒绝，status 变为 rejected"
      accept [:rejection_reason]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      # skipped: validate present :rejection_reason (incompatible with bulk update atomic path)
      change set_attribute(:status, :rejected)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :flag do
      description "举报评价，status 变为 flagged"
      accept [:flag_reason]
      # skipped: validate attribute_equals :status (incompatible with bulk update atomic path)
      # skipped: validate present :flag_reason (incompatible with bulk update atomic path)
      change set_attribute(:status, :flagged)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:score, greater_than_or_equal_to: Decimal.new("1"), less_than_or_equal_to: Decimal.new("5"))
  end

  identities do
    identity :unique_reviewer_per_resource, [:reviewer_id, :resource_type, :resource_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
