# Workflow: forum_management — 论坛管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Forum.Forum do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :mode, :atom do
      constraints one_of: [:questions, :discussions]
      default :questions
      public? true
    end
    attribute :privacy, :atom do
      constraints one_of: [:public, :connected, :authorized]
      default :public
      public? true
    end
    attribute :authorized_group_id, :uuid, public?: true
    attribute :description, :string, public?: true
    attribute :welcome_message, :string, public?: true
    attribute :default_post_type, :atom do
      constraints one_of: [:question, :link, :discussion]
      default :question
      public? true
    end
    attribute :default_order, :string do
      default "relevancy"
      public? true
    end
    attribute :relevancy_post_vote, :decimal do
      default 0.8
      public? true
    end
    attribute :relevancy_time_decay, :decimal do
      default 1.8
      public? true
    end
    attribute :allow_bump, :boolean do
      default false
      public? true
    end
    attribute :allow_share, :boolean do
      default true
      public? true
    end
    attribute :allow_mark_as_offensive, :boolean do
      default true
      public? true
    end
    attribute :karma_gen_question_new, :integer do
      default 2
      public? true
    end
    attribute :karma_gen_question_upvote, :integer do
      default 5
      public? true
    end
    attribute :karma_gen_question_downvote, :integer do
      default -2
      public? true
    end
    attribute :karma_gen_answer_upvote, :integer do
      default 10
      public? true
    end
    attribute :karma_gen_answer_downvote, :integer do
      default -2
      public? true
    end
    attribute :karma_gen_answer_accepted, :integer do
      default 15
      public? true
    end
    attribute :karma_gen_answer_accept, :integer do
      default 2
      public? true
    end
    attribute :karma_gen_question_flagged, :integer do
      default -100
      public? true
    end
    attribute :karma_gen_answer_flagged, :integer do
      default -100
      public? true
    end
    attribute :karma_ask, :integer do
      default 3
      public? true
    end
    attribute :karma_answer, :integer do
      default 3
      public? true
    end
    attribute :karma_upvote, :integer do
      default 5
      public? true
    end
    attribute :karma_downvote, :integer do
      default 50
      public? true
    end
    attribute :karma_comment, :integer do
      default 1
      public? true
    end
    attribute :karma_edit_own, :integer do
      default 1
      public? true
    end
    attribute :karma_edit_all, :integer do
      default 300
      public? true
    end
    attribute :karma_edit_retag, :integer do
      default 75
      public? true
    end
    attribute :karma_close_own, :integer do
      default 100
      public? true
    end
    attribute :karma_close_all, :integer do
      default 500
      public? true
    end
    attribute :karma_unlink_own, :integer do
      default 500
      public? true
    end
    attribute :karma_unlink_all, :integer do
      default 1000
      public? true
    end
    attribute :karma_tag_create, :integer do
      default 30
      public? true
    end
    attribute :karma_answer_accept_own, :integer do
      default 20
      public? true
    end
    attribute :karma_answer_accept_all, :integer do
      default 500
      public? true
    end
    attribute :karma_flag, :integer do
      default 500
      public? true
    end
    attribute :karma_moderate, :integer do
      default 100
      public? true
    end
    attribute :karma_dofollow, :integer do
      default 500
      public? true
    end
    attribute :karma_editor, :integer do
      default 30
      public? true
    end
    attribute :karma_user_bio, :integer do
      default 750
      public? true
    end
    attribute :karma_comment_convert_own, :integer do
      default 50
      public? true
    end
    attribute :karma_comment_convert_all, :integer do
      default 500
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :count_posts_waiting_validation
    # TODO: 不支持的 calculation 表达式 :count_flagged_posts
    # TODO: 不支持的 calculation 表达式 :has_pending_post
    # TODO: 不支持的 calculation 表达式 :can_moderate
    # TODO: 不支持的 calculation 表达式 :tag_most_used_ids
    # TODO: 不支持的 calculation 表达式 :tag_unused_ids
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
      accept [:name, :mode, :privacy, :authorized_group_id, :description, :welcome_message, :default_post_type, :default_order, :relevancy_post_vote, :relevancy_time_decay, :allow_bump, :allow_share, :allow_mark_as_offensive, :karma_gen_question_new, :karma_gen_question_upvote, :karma_gen_question_downvote, :karma_gen_answer_upvote, :karma_gen_answer_downvote, :karma_gen_answer_accepted, :karma_gen_answer_accept, :karma_gen_question_flagged, :karma_gen_answer_flagged, :karma_ask, :karma_answer, :karma_upvote, :karma_downvote, :karma_comment, :karma_edit_own, :karma_edit_all, :karma_edit_retag, :karma_close_own, :karma_close_all, :karma_unlink_own, :karma_unlink_all, :karma_tag_create, :karma_answer_accept_own, :karma_answer_accept_all, :karma_flag, :karma_moderate, :karma_dofollow, :karma_editor, :karma_user_bio, :karma_comment_convert_own, :karma_comment_convert_all]
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
