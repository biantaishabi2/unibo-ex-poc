# Workflow: answer_write_flow — 选项写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Survey.Answer do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "survey_answers"
    repo UniboV4.Repo
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
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :is_correct, :boolean do
      default false
      public? true
    end
    attribute :answer_score, :float do
      default 0.0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :question, UniboV4.Survey.Question do
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
      accept [:value, :sequence, :is_correct, :answer_score]
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
    validate compare(:answer_score, greater_than_or_equal_to: 0)
  end

end
