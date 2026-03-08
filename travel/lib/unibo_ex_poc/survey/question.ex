# Workflow: question_write_flow — 题目写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Survey.Question do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "问卷题目，支持 8 种题目类型（选择/文本/数值/时间/矩阵）"
  end

  postgres do
    table "survey_questions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :survey_question

    queries do
      get :get_survey_question, :read
      list :list_survey_questions, :read
    end

    mutations do
      create :create_survey_question, :create
      update :update_survey_question, :update
      destroy :delete_survey_question, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
      description "题目标题"
    end
    attribute :question_type, :atom do
      allow_nil? false
      constraints one_of: [:simple_choice, :multiple_choice, :char_box, :text_box, :numerical_box, :date, :datetime, :matrix]
      public? true
      description "题目类型"
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "排序序号"
    end
    attribute :constr_mandatory, :boolean do
      default false
      public? true
      description "是否必答"
    end
    attribute :constr_error_msg, :string do
      public? true
      description "必答校验失败提示"
    end
    attribute :comments_allowed, :boolean do
      default false
      public? true
      description "是否允许备注"
    end
    attribute :comment_count_as_answer, :boolean do
      default false
      public? true
      description "备注是否算作回答"
    end
    attribute :validation_email, :boolean do
      default false
      public? true
      description "char_box 是否校验邮箱格式"
    end
    attribute :validation_min_float_value, :float do
      public? true
      description "numerical_box 最小值"
    end
    attribute :validation_max_float_value, :float do
      public? true
      description "numerical_box 最大值"
    end
    attribute :validation_min_date, :date do
      public? true
      description "date 最小值"
    end
    attribute :validation_max_date, :date do
      public? true
      description "date 最大值"
    end
    attribute :matrix_subtype, :atom do
      constraints one_of: [:simple, :multiple]
      default :simple
      public? true
      description "矩阵子类型"
    end
    attribute :save_as_email, :boolean do
      default false
      public? true
      description "char_box 值保存为邮箱"
    end
    attribute :save_as_nickname, :boolean do
      default false
      public? true
      description "char_box 值保存为昵称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_scored_question, :boolean, {UniboExPoc.Survey.Calculations.Question.IsScoredQuestion, []}
  end

  relationships do
    belongs_to :survey, UniboExPoc.Survey.Survey do
      public? true
      allow_nil? false
    end
    belongs_to :page, UniboExPoc.Survey.Question do
      public? true
    end
    has_many :suggested_answer_ids, UniboExPoc.Survey.Answer do
      public? true
    end
    has_many :matrix_row_ids, UniboExPoc.Survey.Answer do
      public? true
    end
    many_to_many :triggering_answer_ids, UniboExPoc.Survey.Answer do
      public? true
      through UniboExPoc.Survey.QuestionTriggerAnswerLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:title, :question_type, :sequence, :constr_mandatory, :constr_error_msg, :comments_allowed, :comment_count_as_answer, :validation_email, :validation_min_float_value, :validation_max_float_value, :validation_min_date, :validation_max_date, :matrix_subtype, :save_as_email, :save_as_nickname]
      argument :survey_id, :uuid, allow_nil?: false
      change manage_relationship(:survey_id, :survey, type: :append, on_lookup: :relate)
      validate present(:title)
      validate present(:question_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:title, :question_type, :sequence, :constr_mandatory, :constr_error_msg, :comments_allowed, :comment_count_as_answer, :validation_email, :validation_min_float_value, :validation_max_float_value, :validation_min_date, :validation_max_date, :matrix_subtype, :save_as_email, :save_as_nickname]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:suggested_answer_ids, :matrix_row_ids]
  end

end
