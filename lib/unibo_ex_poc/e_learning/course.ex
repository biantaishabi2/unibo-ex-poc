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
defmodule UniboExPoc.ELearning.Course do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.ELearning.Course.Notifier]

  resource do
    description "在线课程/频道，承载多个内容项（Slide），管理可见性与注册策略"
  end

  postgres do
    table "e_learning_courses"
    repo UniboExPoc.Repo
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
      description "课程名称"
    end
    attribute :channel_type, :atom do
      constraints one_of: [:training, :documentation]
      default :training
      public? true
      description "课程类型"
    end
    attribute :website_published, :boolean do
      default false
      public? true
      description "是否上线发布"
    end
    attribute :visibility, :atom do
      constraints one_of: [:public, :connected, :members]
      default :public
      public? true
      description "可见性（公开/登录可见/仅会员）"
    end
    attribute :enroll, :atom do
      constraints one_of: [:public, :invite]
      default :public
      public? true
      description "注册策略（自由注册/仅邀请）"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序序号"
    end
    attribute :description, :string do
      public? true
      description "课程简介"
    end
    attribute :description_html, :string do
      public? true
      description "课程详细描述（HTML）"
    end
    attribute :promote_strategy, :atom do
      constraints one_of: [:latest, :most_voted, :most_viewed, :specific, :none]
      default :latest
      public? true
      description "推荐内容策略"
    end
    attribute :total_slides, :integer do
      default 0
      public? true
      description "已发布的非分类 Slide 数量（存储计算字段）"
    end
    attribute :total_views, :integer do
      default 0
      public? true
      description "总浏览次数"
    end
    attribute :total_votes, :integer do
      default 0
      public? true
      description "总投票数"
    end
    attribute :total_time, :decimal do
      default 0
      public? true
      description "总预计时长（小时）"
    end
    attribute :members_count, :integer do
      default 0
      public? true
      description "注册学员总数"
    end
    attribute :members_completed_count, :integer do
      default 0
      public? true
      description "已完课学员数"
    end
    attribute :karma_gen_channel_finish, :integer do
      default 10
      public? true
      description "完课 Karma 奖励"
    end
    attribute :quiz_first_attempt_reward, :integer do
      default 10
      public? true
      description "测验首次通过奖励"
    end
    attribute :quiz_second_attempt_reward, :integer do
      default 7
      public? true
      description "测验第2次通过奖励"
    end
    attribute :quiz_third_attempt_reward, :integer do
      default 5
      public? true
      description "测验第3次通过奖励"
    end
    attribute :quiz_fourth_attempt_reward, :integer do
      default 2
      public? true
      description "测验第4次及以上通过奖励"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :slides, UniboExPoc.ELearning.Slide do
      public? true
      destination_attribute :channel_id
    end
    has_many :enrollments, UniboExPoc.ELearning.Enrollment do
      public? true
      destination_attribute :channel_id
    end
    belongs_to :promoted_slide, UniboExPoc.ELearning.Slide do
      public? true
    end
    belongs_to :created_by, UniboExPoc.ELearning.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :channel_type, :visibility, :enroll, :description, :description_html, :sequence, :promote_strategy, :karma_gen_channel_finish, :quiz_first_attempt_reward, :quiz_second_attempt_reward, :quiz_third_attempt_reward, :quiz_fourth_attempt_reward]
      validate present(:name)
      # validation: visibility_enroll_constraint — 仅会员可见的课程必须设置为仅邀请注册
      change relate_actor(:created_by)
      change UniboExPoc.ELearning.Changes.Course.CreateCreateRelated2
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :channel_type, :visibility, :enroll, :description, :description_html, :sequence, :promote_strategy, :website_published, :karma_gen_channel_finish, :quiz_first_attempt_reward, :quiz_second_attempt_reward, :quiz_third_attempt_reward, :quiz_fourth_attempt_reward]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "上线发布课程"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unpublish do
      description "取消发布课程"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档课程（先归档所有 Slide，再归档课程）"
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :restore do
      description "恢复课程（先恢复课程，再恢复 Slide）"
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_course_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
