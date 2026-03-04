# Workflow: question_write_flow — 题目写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Survey.Question do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "survey_questions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :question_type, :atom do
      allow_nil? false
      constraints one_of: [:simple_choice, :multiple_choice, :char_box, :text_box, :numerical_box, :date, :datetime, :matrix]
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :constr_mandatory, :boolean do
      default false
      public? true
    end
    attribute :constr_error_msg, :string, public?: true
    attribute :comments_allowed, :boolean do
      default false
      public? true
    end
    attribute :comment_count_as_answer, :boolean do
      default false
      public? true
    end
    attribute :validation_email, :boolean do
      default false
      public? true
    end
    attribute :validation_min_float_value, :float, public?: true
    attribute :validation_max_float_value, :float, public?: true
    attribute :validation_min_date, :date, public?: true
    attribute :validation_max_date, :date, public?: true
    attribute :matrix_subtype, :atom do
      constraints one_of: [:simple, :multiple]
      default :simple
      public? true
    end
    attribute :save_as_email, :boolean do
      default false
      public? true
    end
    attribute :save_as_nickname, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_scored_question
  end

  relationships do
    belongs_to :survey, UniboV4.Survey.Survey do
      public? true
      allow_nil? false
    end
    belongs_to :page, UniboV4.Survey.Question do
      public? true
    end
    has_many :suggested_answer_ids, UniboV4.Survey.Answer do
      public? true
    end
    has_many :matrix_row_ids, UniboV4.Survey.Answer do
      public? true
    end
    many_to_many :triggering_answer_ids, UniboV4.Survey.Answer do
      public? true
      through UniboV4.Survey.QuestionTriggerAnswerLink
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
      accept [:title, :question_type, :sequence, :constr_mandatory, :constr_error_msg, :comments_allowed, :comment_count_as_answer, :validation_email, :validation_min_float_value, :validation_max_float_value, :validation_min_date, :validation_max_date, :matrix_subtype, :save_as_email, :save_as_nickname]
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

end
