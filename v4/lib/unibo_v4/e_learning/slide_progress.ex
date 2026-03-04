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
    otp_app: :unibo_v4,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "e_learning_slide_progresses"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :completed, :boolean do
      default false
      public? true
    end
    attribute :quiz_attempts_count, :integer do
      default 0
      public? true
    end
    attribute :vote, :integer do
      default 0
      public? true
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
    belongs_to :partner, UniboV4.ELearning.User do
      public? true
      allow_nil? false
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :mark_completed do
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
      # TODO: 不支持的 change effect recompute_parent
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
    update :mark_uncompleted do
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
      # TODO: 不支持的 change effect recompute_parent
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
    update :complete_quiz do
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
      # TODO: 不支持的 change effect increment
      # TODO: 不支持的 change effect recompute_parent
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
    update :action_like do
      accept []
      # TODO: 不支持的 change effect toggle_vote
      # TODO: 不支持的 change effect recompute_parent
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
    update :action_dislike do
      accept []
      # TODO: 不支持的 change effect toggle_vote
      # TODO: 不支持的 change effect recompute_parent
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

  identities do
    identity :unique_slide_progress, [:slide_id, :partner_id]
  end

end
