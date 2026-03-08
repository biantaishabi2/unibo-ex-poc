# Workflow: answering_flow — 答题流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> mark_in_progress
#   mark_in_progress --> mark_done
#   mark_done --> [*] : done
# ```
defmodule UniboV4.Survey.UserInput do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Survey.UserInput.Notifier]

  resource do
    description "用户答题记录，跟踪答题状态、时间和得分"
  end

  postgres do
    table "survey_user_inputs"
    repo UniboV4.Repo
  end

  graphql do
    type :survey_user_input

    queries do
      get :get_survey_user_input, :read
      list :list_survey_user_inputs, :read
    end

    mutations do
      create :create_survey_user_input, :create
      update :mark_in_progress_survey_user_input, :mark_in_progress
      update :mark_done_survey_user_input, :mark_done
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:new, :in_progress, :done]
      default :new
      public? true
      description "答题状态"
    end
    attribute :start_datetime, :utc_datetime do
      public? true
      description "开始时间"
    end
    attribute :end_datetime, :utc_datetime do
      public? true
      description "完成时间"
    end
    attribute :deadline, :utc_datetime do
      public? true
      description "截止时间"
    end
    attribute :access_token, :uuid do
      allow_nil? false
      public? true
      description "访问令牌"
    end
    attribute :invite_token, :uuid do
      public? true
      description "邀请令牌（token 模式）"
    end
    attribute :email, :string do
      public? true
      description "答题者邮箱"
    end
    attribute :nickname, :string do
      public? true
      description "答题者昵称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :scoring_total, :float, expr(sum(lines, field: :answer_score, query: [filter: expr(true)]))
    calculate :scoring_percentage, :float, expr(((scoring_total * 100) / survey.scoring_max_obtainable))
    calculate :scoring_success, :boolean, expr(scoring_percentage >= survey.scoring_success_min)
    calculate :survey_time_limit_reached, :boolean, expr(now() > (start_datetime + survey.time_limit))
  end

  relationships do
    belongs_to :survey, UniboV4.Survey.Survey do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Survey.Party do
      public? true
      source_attribute :partner_party_id
    end
    has_many :lines, UniboV4.Survey.UserInputLine do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:email, :nickname, :invite_token]
      argument :survey_id, :uuid, allow_nil?: false
      change manage_relationship(:survey_id, :survey, type: :append, on_lookup: :relate)
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, type: :create)
      change set_attribute(:id, expr(id))
    end
    update :mark_in_progress do
      description "开始答题"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有新建状态可以开始答题"
      change set_attribute(:state, :in_progress)
      change UniboV4.Survey.Changes.UserInput.ComputeStartDatetime
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_done do
      description "完成答题"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以完成答题"
      change set_attribute(:state, :done)
      change UniboV4.Survey.Changes.UserInput.ComputeEndDatetime
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
