# Workflow: user_input_line_write_flow — 答案行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Survey.UserInputLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :value_text_box, :string, public?: true
    attribute :value_char_box, :string, public?: true
    attribute :value_numerical_box, :float, public?: true
    attribute :value_date, :date, public?: true
    attribute :value_datetime, :utc_datetime, public?: true
    attribute :answer_score, :float, public?: true
    attribute :answer_is_correct, :boolean, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
