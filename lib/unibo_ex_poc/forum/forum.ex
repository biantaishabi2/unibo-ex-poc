# Workflow: forum_management — 论坛管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Forum.Forum do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "论坛实例，承载 Karma 阈值配置与全局设置"
  end

  postgres do
    table "forum_forums"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_forum

    queries do
      get :get_forum_forum, :read
      list :list_forum_forums, :read
    end

    mutations do
      create :create_forum_forum, :create
      update :update_forum_forum, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "论坛名称"
    end
    attribute :mode, :atom do
      constraints one_of: [:questions, :discussions]
      default :questions
      public? true
      description "论坛模式（questions=单一最佳答案，discussions=多答案讨论）"
    end
    attribute :privacy, :atom do
      constraints one_of: [:public, :connected, :authorized]
      default :public
      public? true
      description "访问权限（public=公开，connected=需登录，authorized=指定用户组）"
    end
    attribute :authorized_group_id, :uuid do
      public? true
      description "privacy=authorized 时的授权用户组"
    end
    attribute :description, :string do
      public? true
      description "论坛描述"
    end
    attribute :welcome_message, :string do
      public? true
      description "欢迎消息"
    end
    attribute :default_post_type, :atom do
      constraints one_of: [:question, :link, :discussion]
      default :question
      public? true
      description "新帖默认类型"
    end
    attribute :default_order, :string do
      default "relevancy"
      public? true
      description "默认排序方式"
    end
    attribute :relevancy_post_vote, :decimal do
      default 0.8
      public? true
      description "投票相关性指数"
    end
    attribute :relevancy_time_decay, :decimal do
      default 1.8
      public? true
      description "时间衰减指数"
    end
    attribute :allow_bump, :boolean do
      default false
      public? true
      description "是否允许顶帖"
    end
    attribute :allow_share, :boolean do
      default true
      public? true
      description "是否允许分享"
    end
    attribute :allow_mark_as_offensive, :boolean do
      default true
      public? true
      description "是否允许标记冒犯"
    end
    attribute :karma_gen_question_new, :integer do
      default 2
      public? true
      description "发新问题获得的 Karma"
    end
    attribute :karma_gen_question_upvote, :integer do
      default 5
      public? true
      description "问题被赞获得的 Karma"
    end
    attribute :karma_gen_question_downvote, :integer do
      default -2
      public? true
      description "问题被踩扣除的 Karma"
    end
    attribute :karma_gen_answer_upvote, :integer do
      default 10
      public? true
      description "回答被赞获得的 Karma"
    end
    attribute :karma_gen_answer_downvote, :integer do
      default -2
      public? true
      description "回答被踩扣除的 Karma"
    end
    attribute :karma_gen_answer_accepted, :integer do
      default 15
      public? true
      description "回答被采纳时回答者获得的 Karma"
    end
    attribute :karma_gen_answer_accept, :integer do
      default 2
      public? true
      description "提问者采纳回答获得的 Karma"
    end
    attribute :karma_gen_question_flagged, :integer do
      default -100
      public? true
      description "问题被标记冒犯时扣除的 Karma"
    end
    attribute :karma_gen_answer_flagged, :integer do
      default -100
      public? true
      description "回答被标记冒犯时扣除的 Karma"
    end
    attribute :karma_ask, :integer do
      default 3
      public? true
      description "提问所需最低 Karma"
    end
    attribute :karma_answer, :integer do
      default 3
      public? true
      description "回答所需最低 Karma"
    end
    attribute :karma_upvote, :integer do
      default 5
      public? true
      description "点赞所需最低 Karma"
    end
    attribute :karma_downvote, :integer do
      default 50
      public? true
      description "点踩所需最低 Karma"
    end
    attribute :karma_comment, :integer do
      default 1
      public? true
      description "评论所需最低 Karma"
    end
    attribute :karma_edit_own, :integer do
      default 1
      public? true
      description "编辑自己帖子所需最低 Karma"
    end
    attribute :karma_edit_all, :integer do
      default 300
      public? true
      description "编辑所有帖子所需最低 Karma"
    end
    attribute :karma_edit_retag, :integer do
      default 75
      public? true
      description "修改标签所需最低 Karma"
    end
    attribute :karma_close_own, :integer do
      default 100
      public? true
      description "关闭自己帖子所需最低 Karma"
    end
    attribute :karma_close_all, :integer do
      default 500
      public? true
      description "关闭所有帖子所需最低 Karma"
    end
    attribute :karma_unlink_own, :integer do
      default 500
      public? true
      description "删除自己帖子所需最低 Karma"
    end
    attribute :karma_unlink_all, :integer do
      default 1000
      public? true
      description "删除所有帖子所需最低 Karma"
    end
    attribute :karma_tag_create, :integer do
      default 30
      public? true
      description "创建标签所需最低 Karma"
    end
    attribute :karma_answer_accept_own, :integer do
      default 20
      public? true
      description "采纳自己问题答案所需最低 Karma"
    end
    attribute :karma_answer_accept_all, :integer do
      default 500
      public? true
      description "采纳所有问题答案所需最低 Karma"
    end
    attribute :karma_flag, :integer do
      default 500
      public? true
      description "标记冒犯所需最低 Karma"
    end
    attribute :karma_moderate, :integer do
      default 100
      public? true
      description "免审核发帖所需最低 Karma"
    end
    attribute :karma_dofollow, :integer do
      default 500
      public? true
      description "dofollow 链接所需最低 Karma"
    end
    attribute :karma_editor, :integer do
      default 30
      public? true
      description "富文本编辑器所需最低 Karma"
    end
    attribute :karma_user_bio, :integer do
      default 750
      public? true
      description "显示用户简介所需最低 Karma"
    end
    attribute :karma_comment_convert_own, :integer do
      default 50
      public? true
      description "转换自己评论类型所需最低 Karma"
    end
    attribute :karma_comment_convert_all, :integer do
      default 500
      public? true
      description "转换所有评论类型所需最低 Karma"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :count_posts_waiting_validation, :integer, {UniboV4.Forum.Calculations.Forum.CountPostsWaitingValidation, []}
    calculate :count_flagged_posts, :integer, {UniboV4.Forum.Calculations.Forum.CountFlaggedPosts, []}
    calculate :has_pending_post, :boolean, expr(exists())
    calculate :can_moderate, :boolean, expr(actor.karma >= karma_moderate)
    calculate :tag_most_used_ids, {:array, :string}, expr(take(5))
    calculate :tag_unused_ids, {:array, :string}, {UniboV4.Forum.Calculations.Forum.TagUnusedIds, []}
  end

  relationships do
    has_many :posts, UniboV4.Forum.Post do
      public? true
    end
    has_many :tags, UniboV4.Forum.Tag do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :mode, :privacy, :authorized_group_id, :description, :welcome_message, :default_post_type, :default_order, :relevancy_post_vote, :relevancy_time_decay, :allow_bump, :allow_share, :allow_mark_as_offensive, :karma_gen_question_new, :karma_gen_question_upvote, :karma_gen_question_downvote, :karma_gen_answer_upvote, :karma_gen_answer_downvote, :karma_gen_answer_accepted, :karma_gen_answer_accept, :karma_gen_question_flagged, :karma_gen_answer_flagged, :karma_ask, :karma_answer, :karma_upvote, :karma_downvote, :karma_comment, :karma_edit_own, :karma_edit_all, :karma_edit_retag, :karma_close_own, :karma_close_all, :karma_unlink_own, :karma_unlink_all, :karma_tag_create, :karma_answer_accept_own, :karma_answer_accept_all, :karma_flag, :karma_moderate, :karma_dofollow, :karma_editor, :karma_user_bio, :karma_comment_convert_own, :karma_comment_convert_all]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :mode, :privacy, :authorized_group_id, :description, :welcome_message, :default_post_type, :default_order, :relevancy_post_vote, :relevancy_time_decay, :allow_bump, :allow_share, :allow_mark_as_offensive, :karma_gen_question_new, :karma_gen_question_upvote, :karma_gen_question_downvote, :karma_gen_answer_upvote, :karma_gen_answer_downvote, :karma_gen_answer_accepted, :karma_gen_answer_accept, :karma_gen_question_flagged, :karma_gen_answer_flagged, :karma_ask, :karma_answer, :karma_upvote, :karma_downvote, :karma_comment, :karma_edit_own, :karma_edit_all, :karma_edit_retag, :karma_close_own, :karma_close_all, :karma_unlink_own, :karma_unlink_all, :karma_tag_create, :karma_answer_accept_own, :karma_answer_accept_all, :karma_flag, :karma_moderate, :karma_dofollow, :karma_editor, :karma_user_bio, :karma_comment_convert_own, :karma_comment_convert_all]
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
