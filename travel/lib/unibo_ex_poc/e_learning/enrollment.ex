# Workflow: enrollment_lifecycle — 学员注册生命周期（邀请→加入→学习中→完课）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> join
#   create --> recompute_completion
#   create --> destroy
#   join --> recompute_completion
#   recompute_completion --> recompute_completion
#   destroy --> [*]
# ```
defmodule UniboExPoc.ELearning.Enrollment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.ELearning.Enrollment.Notifier]

  resource do
    description "学员与课程的注册关系，跟踪学习进度和完成状态"
  end

  postgres do
    table "e_learning_enrollments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :e_learning_enrollment

    queries do
      get :get_e_learning_enrollment, :read
      list :list_e_learning_enrollments, :read
    end

    mutations do
      create :create_e_learning_enrollment, :create
      update :join_e_learning_enrollment, :join
      update :recompute_completion_e_learning_enrollment, :recompute_completion
      destroy :delete_e_learning_enrollment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :member_status, :atom do
      allow_nil? false
      constraints one_of: [:invited, :joined, :ongoing, :completed]
      default :joined
      public? true
      description "注册状态"
    end
    attribute :completion, :integer do
      default 0
      public? true
      description "完成百分比（0-100）"
    end
    attribute :completed_slides_count, :integer do
      default 0
      public? true
      description "已完成的 Slide 数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :next_slide_id, :uuid, expr(next_uncompleted_slide(channel_id, partner_id))
  end

  relationships do
    belongs_to :channel, UniboExPoc.ELearning.Course do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.ELearning.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
    has_many :slide_progress, UniboExPoc.ELearning.SlideProgress do
      public? true
      destination_attribute :enrollment_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:member_status]
      argument :channel_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      # validation: prerequisite_check — 必须完成所有前置课程才能加入
      change set_attribute(:id, expr(id))
    end
    update :join do
      description "接受邀请加入课程"
      primary? true
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :member_status)
        if current == :invited do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :member_status, message: "must equal %{value}", vars: %{value: :invited}))
        end
      end
      # message: "只有受邀状态可以执行加入操作"
      change set_attribute(:member_status, :joined)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :recompute_completion do
      description "重新计算完成度（由 SlideProgress 变更触发）"
      accept []
      change UniboExPoc.ELearning.Changes.Enrollment.ComputeCompletion
      change set_attribute(:member_status, :ongoing)
      change set_attribute(:member_status, :completed)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "清理过期邀请（GC 定时任务）"
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_enrollment, [:channel_id, :partner_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:slide_progress]
  end

end
