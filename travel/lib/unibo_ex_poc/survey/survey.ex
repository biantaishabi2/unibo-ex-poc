# Workflow: survey_lifecycle — 问卷生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> action_open
#   action_open --> action_close
#   action_close --> action_draft
#   action_draft --> action_open
# ```
# Workflow: survey_edit_flow — 问卷编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Survey.Survey do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Survey.Survey.Notifier]

  resource do
    description "问卷主体，支持普通问卷、实时会话、认证考试等多种类型"
  end

  postgres do
    table "survey_surveys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :survey_survey

    queries do
      get :get_survey_survey, :read
      list :list_survey_surveys, :read
    end

    mutations do
      create :create_survey_survey, :create
      update :update_survey_survey, :update
      update :action_open_survey_survey, :action_open
      update :action_close_survey_survey, :action_close
      update :action_draft_survey_survey, :action_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
      description "问卷标题"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :open, :closed]
      default :draft
      public? true
      description "状态：草稿 / 已发布 / 已关闭"
    end
    attribute :survey_type, :atom do
      constraints one_of: [:survey, :live_session, :assessment, :custom]
      default :survey
      public? true
      description "问卷类型"
    end
    attribute :access_mode, :atom do
      constraints one_of: [:public, :token, :authentication]
      default :public
      public? true
      description "访问模式：公开 / 令牌邀请 / 需登录"
    end
    attribute :users_login_required, :boolean do
      default false
      public? true
      description "public 模式下是否要求登录"
    end
    attribute :access_token, :uuid do
      allow_nil? false
      public? true
      description "自动生成的访问令牌"
    end
    attribute :questions_layout, :atom do
      constraints one_of: [:one_page, :page_per_section, :page_per_question]
      default :one_page
      public? true
      description "布局模式"
    end
    attribute :questions_selection, :atom do
      constraints one_of: [:all, :random]
      default :all
      public? true
      description "题目选择模式"
    end
    attribute :random_questions_count, :integer do
      public? true
      description "随机抽题数量（每个分区）"
    end
    attribute :scoring_type, :atom do
      constraints one_of: [:no_scoring, :scoring_with_answers, :scoring_with_answers_after_page, :scoring_without_answers]
      default :no_scoring
      public? true
      description "评分模式"
    end
    attribute :scoring_success_min, :float do
      default 80.0
      public? true
      description "及格线百分比"
    end
    attribute :is_time_limited, :boolean do
      default false
      public? true
      description "是否限时"
    end
    attribute :time_limit, :float do
      public? true
      description "时限（分钟）"
    end
    attribute :is_attempts_limited, :boolean do
      default false
      public? true
      description "是否限制答题次数"
    end
    attribute :attempts_limit, :integer do
      public? true
      description "最大尝试次数"
    end
    attribute :certification_give_badge, :boolean do
      default false
      public? true
      description "及格后是否授予徽章"
    end
    attribute :session_state, :atom do
      constraints one_of: [:ready, :in_progress]
      public? true
      description "实时会话状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :answer_count, :integer, expr(count(user_inputs, query: [filter: expr(true)]))
    calculate :answer_done_count, :integer, expr(count(user_inputs, query: [filter: expr(true)]))
    calculate :success_count, :integer, expr(count(user_inputs, query: [filter: expr(true)]))
    calculate :answer_score_avg, :float, expr(avg(user_inputs, field: :scoring_percentage, query: [filter: expr(true)]))
    calculate :success_ratio, :float, expr(((success_count * 100) / answer_count))
    calculate :answer_duration_avg, :float, {UniboExPoc.Survey.Calculations.Survey.AnswerDurationAvg, []}
    calculate :question_count, :integer, expr(count(questions, query: [filter: expr(true)]))
    calculate :scoring_max_obtainable, :float, {UniboExPoc.Survey.Calculations.Survey.ScoringMaxObtainable, []}
  end

  relationships do
    has_many :question_and_page_ids, UniboExPoc.Survey.Question do
      public? true
    end
    has_many :questions, UniboExPoc.Survey.Question do
      public? true
    end
    has_many :page_ids, UniboExPoc.Survey.Question do
      public? true
    end
    has_many :user_inputs, UniboExPoc.Survey.UserInput do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :survey_type, :access_mode, :users_login_required, :questions_layout, :questions_selection, :random_questions_count, :scoring_type, :scoring_success_min, :is_time_limited, :time_limit, :is_attempts_limited, :attempts_limit, :certification_give_badge]
      validate present(:title)
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
      accept [:title, :survey_type, :access_mode, :users_login_required, :questions_layout, :questions_selection, :random_questions_count, :scoring_type, :scoring_success_min, :is_time_limited, :time_limit, :is_attempts_limited, :attempts_limit, :certification_give_badge]
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
    update :action_open do
      description "发布问卷"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      change set_attribute(:state, :open)
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
    update :action_close do
      description "关闭问卷"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :open do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :open}))
        end
      end
      # message: "只有已发布状态可以关闭"
      change set_attribute(:state, :closed)
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
    update :action_draft do
      description "重置为草稿（从已关闭状态）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :closed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :closed}))
        end
      end
      # message: "只有已关闭状态可以重置为草稿"
      change set_attribute(:state, :draft)
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
    validate compare(:time_limit, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
