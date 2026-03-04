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
    otp_app: :unibo_v4,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Survey.UserInput.Notifier]

  postgres do
    table "survey_user_inputs"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:new, :in_progress, :done]
      default :new
      public? true
    end
    attribute :start_datetime, :utc_datetime, public?: true
    attribute :end_datetime, :utc_datetime, public?: true
    attribute :deadline, :utc_datetime, public?: true
    attribute :access_token, :uuid do
      allow_nil? false
      public? true
    end
    attribute :invite_token, :uuid, public?: true
    attribute :email, :string, public?: true
    attribute :nickname, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :scoring_total, :float, expr(sum(lines, field: :answer_score, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :scoring_percentage
    # TODO: 不支持的 calculation 表达式 :scoring_success
    # TODO: 不支持的 calculation 表达式 :survey_time_limit_reached
  end

  relationships do
    belongs_to :survey, UniboV4.Survey.Survey do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Survey.Partner do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :mark_in_progress do
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
      # TODO: 跨实体聚合表达式暂不支持
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
    update :mark_done do
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
      # TODO: 跨实体聚合表达式暂不支持
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
