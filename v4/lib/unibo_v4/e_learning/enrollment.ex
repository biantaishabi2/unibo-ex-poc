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
defmodule UniboV4.ELearning.Enrollment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.ELearning.Enrollment.Notifier]

  postgres do
    table "e_learning_enrollments"
    repo UniboV4.Repo
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
    end
    attribute :completion, :integer do
      default 0
      public? true
    end
    attribute :completed_slides_count, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :next_slide_id
  end

  relationships do
    belongs_to :channel, UniboV4.ELearning.Course do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.ELearning.User do
      public? true
      allow_nil? false
    end
    has_many :slide_progress, UniboV4.ELearning.SlideProgress do
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
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :join do
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
    update :recompute_completion do
      accept []
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:member_status, :ongoing)
      change set_attribute(:member_status, :completed)
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
    destroy :destroy do
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

  identities do
    identity :unique_enrollment, [:channel_id, :partner_id]
  end

end
