# Workflow: progress_tracking — 学习进度跟踪（创建→完成/取消完成 + 投票）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> mark_completed
#   create --> complete_quiz
#   create --> action_like
#   create --> action_dislike
#   mark_completed --> mark_uncompleted
#   mark_completed --> action_like
#   mark_completed --> action_dislike
#   mark_uncompleted --> mark_completed
#   mark_uncompleted --> complete_quiz
#   mark_uncompleted --> action_like
#   mark_uncompleted --> action_dislike
#   complete_quiz --> mark_uncompleted
#   complete_quiz --> action_like
#   complete_quiz --> action_dislike
#   action_like --> action_like
#   action_like --> action_dislike
#   action_dislike --> action_like
#   action_dislike --> action_dislike
# ```
defmodule UniboV4.ELearning.SlideProgress do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "用户对单个内容项的学习进度，包括完成状态、测验尝试、投票"
  end

  postgres do
    table "e_learning_slide_progresses"
    repo UniboV4.Repo
  end

  graphql do
    type :e_learning_slide_progress

    queries do
      get :get_e_learning_slide_progress, :read
      list :list_e_learning_slide_progresss, :read
    end

    mutations do
      create :create_e_learning_slide_progress, :create
      update :mark_completed_e_learning_slide_progress, :mark_completed
      update :mark_uncompleted_e_learning_slide_progress, :mark_uncompleted
      update :complete_quiz_e_learning_slide_progress, :complete_quiz
      update :action_like_e_learning_slide_progress, :action_like
      update :action_dislike_e_learning_slide_progress, :action_dislike
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :completed, :boolean do
      default false
      public? true
      description "是否完成该内容项"
    end
    attribute :quiz_attempts_count, :integer do
      default 0
      public? true
      description "测验尝试次数"
    end
    attribute :vote, :integer do
      default 0
      public? true
      description "投票（-1=踩, 0=无, 1=赞）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :slide, UniboV4.ELearning.Slide do
      public? true
      allow_nil? false
    end
    belongs_to :channel, UniboV4.ELearning.Course do
      public? true
      allow_nil? false
    end
    belongs_to :enrollment, UniboV4.ELearning.Enrollment do
      public? true
    end
    belongs_to :partner, UniboV4.ELearning.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept []
      argument :slide_id, :uuid, allow_nil?: false
      argument :channel_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:slide_id, :slide, type: :append, on_lookup: :relate)
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :mark_completed do
      description "手动标记完成（非测验类型）"
      primary? true
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :completed)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :completed, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "该内容项已标记为完成"
      change set_attribute(:completed, true)
      change UniboV4.ELearning.Changes.SlideProgress.MarkCompletedCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_uncompleted do
      description "取消完成标记"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :completed)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :completed, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "该内容项尚未完成"
      change set_attribute(:completed, false)
      change UniboV4.ELearning.Changes.SlideProgress.MarkUncompletedCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete_quiz do
      description "测验答题完成（仅 quiz 类型）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :completed)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :completed, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "该内容项已标记为完成"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:completed, true)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :quiz_attempts_count) || 0
        Ash.Changeset.force_change_attribute(changeset, :quiz_attempts_count, current + 1)
      end
      change UniboV4.ELearning.Changes.SlideProgress.CompleteQuizCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_like do
      description "点赞/取消点赞（toggle 语义）"
      accept []
      change UniboV4.ELearning.Changes.SlideProgress.ActionLikeCall4
      change UniboV4.ELearning.Changes.SlideProgress.ActionLikeCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_dislike do
      description "踩/取消踩（toggle 语义）"
      accept []
      change UniboV4.ELearning.Changes.SlideProgress.ActionDislikeCall5
      change UniboV4.ELearning.Changes.SlideProgress.ActionDislikeCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_slide_progress, [:slide_id, :partner_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
