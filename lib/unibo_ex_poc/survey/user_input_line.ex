# Workflow: user_input_line_write_flow — 答案行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Survey.UserInputLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用户针对单个题目的作答记录，按题目类型使用不同的值字段"
  end

  postgres do
    table "survey_user_input_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :survey_user_input_line

    queries do
      get :get_survey_user_input_line, :read
      list :list_survey_user_input_lines, :read
    end

    mutations do
      create :create_survey_user_input_line, :create
      destroy :delete_survey_user_input_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :answer_type, :atom do
      allow_nil? false
      constraints one_of: [:simple_choice, :multiple_choice, :char_box, :text_box, :numerical_box, :date, :datetime, :matrix]
      public? true
      description "答案类型（对应 question_type）"
    end
    attribute :value_text_box, :string do
      public? true
      description "text_box 答案"
    end
    attribute :value_char_box, :string do
      public? true
      description "char_box 答案"
    end
    attribute :value_numerical_box, :float do
      public? true
      description "numerical_box 答案"
    end
    attribute :value_date, :date do
      public? true
      description "date 答案"
    end
    attribute :value_datetime, :utc_datetime do
      public? true
      description "datetime 答案"
    end
    attribute :answer_score, :float do
      public? true
      description "该行得分"
    end
    attribute :answer_is_correct, :boolean do
      public? true
      description "该行是否正确"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user_input, UniboV4.Survey.UserInput do
      public? true
      allow_nil? false
    end
    belongs_to :question, UniboV4.Survey.Question do
      public? true
      allow_nil? false
    end
    belongs_to :suggested_answer, UniboV4.Survey.Answer do
      public? true
    end
    belongs_to :matrix_row, UniboV4.Survey.Answer do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:answer_type, :value_text_box, :value_char_box, :value_numerical_box, :value_date, :value_datetime]
      argument :user_input_id, :uuid, allow_nil?: false
      argument :question_id, :uuid, allow_nil?: false
      argument :suggested_answer_id, :uuid
      argument :matrix_row_id, :uuid
      change manage_relationship(:user_input_id, :user_input, type: :append, on_lookup: :relate)
      change manage_relationship(:question_id, :question, type: :append, on_lookup: :relate)
      validate present(:answer_type)
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
