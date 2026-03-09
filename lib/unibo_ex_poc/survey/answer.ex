# Workflow: answer_write_flow — 选项写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Survey.Answer do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "题目选项，用于选择题和矩阵题的候选答案"
  end

  postgres do
    table "survey_answers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :survey_answer

    queries do
      get :get_survey_answer, :read
      list :list_survey_answers, :read
    end

    mutations do
      create :create_survey_answer, :create
      update :update_survey_answer, :update
      destroy :delete_survey_answer, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :value, :string do
      allow_nil? false
      public? true
      description "选项文本"
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "排序序号"
    end
    attribute :is_correct, :boolean do
      default false
      public? true
      description "是否为正确答案"
    end
    attribute :answer_score, :float do
      default 0.0
      public? true
      description "得分值"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :question, UniboExPoc.Survey.Question do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:value, :sequence, :is_correct, :answer_score]
      argument :question_id, :uuid, allow_nil?: false
      change manage_relationship(:question_id, :question, type: :append, on_lookup: :relate)
      validate present(:value)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:value, :sequence, :is_correct, :answer_score]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:answer_score, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
