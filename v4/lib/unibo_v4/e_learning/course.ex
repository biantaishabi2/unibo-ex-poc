# Workflow: course_lifecycle — 课程生命周期（创建→发布→归档/恢复）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> update
#   update --> publish
#   update --> archive
#   publish --> unpublish
#   publish --> archive
#   unpublish --> update
#   unpublish --> publish
#   unpublish --> archive
#   archive --> restore
#   restore --> update
#   restore --> publish
# ```
defmodule UniboV4.ELearning.Course do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.ELearning.Course.Notifier]

  postgres do
    table "e_learning_courses"
    repo UniboV4.Repo
  end

  graphql do
    type :e_learning_course

    queries do
      get :get_e_learning_course, :read
      list :list_e_learning_courses, :read
    end

    mutations do
      create :create_e_learning_course, :create
      update :update_e_learning_course, :update
      update :publish_e_learning_course, :publish
      update :unpublish_e_learning_course, :unpublish
      update :archive_e_learning_course, :archive
      update :restore_e_learning_course, :restore
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :channel_type, :atom do
      constraints one_of: [:training, :documentation]
      default :training
      public? true
    end
    attribute :website_published, :boolean do
      default false
      public? true
    end
    attribute :visibility, :atom do
      constraints one_of: [:public, :connected, :members]
      default :public
      public? true
    end
    attribute :enroll, :atom do
      constraints one_of: [:public, :invite]
      default :public
      public? true
    end
    attribute :sequence, :integer do
      default 0
      public? true
    end
    attribute :description, :string, public?: true
    attribute :description_html, :string, public?: true
    attribute :promote_strategy, :atom do
      constraints one_of: [:latest, :most_voted, :most_viewed, :specific, :none]
      default :latest
      public? true
    end
    attribute :total_slides, :integer do
      default 0
      public? true
    end
    attribute :total_views, :integer do
      default 0
      public? true
    end
    attribute :total_votes, :integer do
      default 0
      public? true
    end
    attribute :total_time, :decimal do
      default 0
      public? true
    end
    attribute :members_count, :integer do
      default 0
      public? true
    end
    attribute :members_completed_count, :integer do
      default 0
      public? true
    end
    attribute :karma_gen_channel_finish, :integer do
      default 10
      public? true
    end
    attribute :quiz_first_attempt_reward, :integer do
      default 10
      public? true
    end
    attribute :quiz_second_attempt_reward, :integer do
      default 7
      public? true
    end
    attribute :quiz_third_attempt_reward, :integer do
      default 5
      public? true
    end
    attribute :quiz_fourth_attempt_reward, :integer do
      default 2
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :slides, UniboV4.ELearning.Slide do
      public? true
      destination_attribute :channel_id
    end
    has_many :enrollments, UniboV4.ELearning.Enrollment do
      public? true
      destination_attribute :channel_id
    end
    belongs_to :promoted_slide, UniboV4.ELearning.Slide do
      public? true
    end
    belongs_to :created_by, UniboV4.ELearning.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :channel_type, :visibility, :enroll, :description, :description_html, :sequence, :promote_strategy, :karma_gen_channel_finish, :quiz_first_attempt_reward, :quiz_second_attempt_reward, :quiz_third_attempt_reward, :quiz_fourth_attempt_reward]
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
      change relate_actor(:created_by)
      # TODO: 不支持的 change effect create_related
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
      accept [:name, :channel_type, :visibility, :enroll, :description, :description_html, :sequence, :promote_strategy, :website_published, :karma_gen_channel_finish, :quiz_first_attempt_reward, :quiz_second_attempt_reward, :quiz_third_attempt_reward, :quiz_fourth_attempt_reward]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :publish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :website_published)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :website_published, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "课程已处于发布状态"
      change set_attribute(:website_published, true)
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
    update :unpublish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :website_published)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :website_published, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "课程未发布，无法取消发布"
      change set_attribute(:website_published, false)
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
    update :archive do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :restore do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    identity :unique_course_name, [:name]
  end

end
