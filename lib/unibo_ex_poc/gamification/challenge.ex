# Workflow: challenge_flow — 挑战生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> action_start
#   update --> update
#   update --> action_start
#   action_start --> action_check
#   action_start --> action_done
#   action_check --> action_check
#   action_check --> action_done
#   action_done --> [*] : done
# ```
defmodule UniboV4.Gamification.Challenge do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Gamification.Challenge.Notifier]

  resource do
    description "挑战，包含参与者、目标行列表、周期配置和奖励规则"
  end

  postgres do
    table "gamification_challenges"
    repo UniboV4.Repo
  end

  graphql do
    type :gamification_challenge

    queries do
      get :get_gamification_challenge, :read
      list :list_gamification_challenges, :read
    end

    mutations do
      create :create_gamification_challenge, :create
      update :update_gamification_challenge, :update
      update :action_start_gamification_challenge, :action_start
      update :action_check_gamification_challenge, :action_check
      update :action_done_gamification_challenge, :action_done
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "挑战名称"
    end
    attribute :description, :string do
      public? true
      description "挑战描述"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :inprogress, :done]
      default :draft
      public? true
      description "挑战状态"
    end
    attribute :user_domain, :string do
      public? true
      description "用户域（动态计算参与者的过滤表达式）"
    end
    attribute :period, :atom do
      constraints one_of: [:once, :daily, :weekly, :monthly, :yearly]
      default :once
      public? true
      description "挑战周期"
    end
    attribute :start_date, :date do
      public? true
      description "开始日期"
    end
    attribute :end_date, :date do
      public? true
      description "结束日期"
    end
    attribute :reward_failure, :boolean do
      default false
      public? true
      description "未全部成功时是否也奖励最佳用户"
    end
    attribute :reward_realtime, :boolean do
      default true
      public? true
      description "达标后是否即时奖励"
    end
    attribute :visibility_mode, :atom do
      constraints one_of: [:personal, :ranking]
      default :personal
      public? true
      description "可见模式（个人/排名）"
    end
    attribute :report_message_frequency, :atom do
      constraints one_of: [:never, :onchange, :daily, :weekly, :monthly, :yearly]
      default :never
      public? true
      description "报告频率"
    end
    attribute :remind_update_delay, :integer do
      public? true
      description "手动目标提醒延迟天数"
    end
    attribute :last_report_date, :date do
      public? true
      description "上次报告日期"
    end
    attribute :challenge_category, :atom do
      constraints one_of: [:hr, :other]
      default :other
      public? true
      description "挑战分类"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :user_count, :integer, {UniboV4.Gamification.Calculations.Challenge.UserCount, []}
    calculate :next_report_date, :date, expr(compute_next_report_date(report_message_frequency, last_report_date))
  end

  relationships do
    belongs_to :manager, UniboV4.Gamification.Party do
      public? true
      source_attribute :manager_party_id
    end
    belongs_to :reward, UniboV4.Gamification.Badge do
      public? true
    end
    belongs_to :reward_first, UniboV4.Gamification.Badge do
      public? true
    end
    belongs_to :reward_second, UniboV4.Gamification.Badge do
      public? true
    end
    belongs_to :reward_third, UniboV4.Gamification.Badge do
      public? true
    end
    has_many :line_ids, UniboV4.Gamification.ChallengeLine do
      public? true
      destination_attribute :challenge_id
    end
    many_to_many :user_ids, UniboV4.Gamification.Party do
      public? true
      through UniboV4.Gamification.ChallengeUserLink
      destination_attribute_on_join_resource :user_party_id
    end
    many_to_many :invited_user_ids, UniboV4.Gamification.Party do
      public? true
      through UniboV4.Gamification.ChallengeInvitedUserLink
      destination_attribute_on_join_resource :user_party_id
    end
    has_many :translations, UniboV4.Gamification.ChallengeTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :state, :user_domain, :period, :start_date, :end_date, :reward_failure, :reward_realtime, :visibility_mode, :report_message_frequency, :remind_update_delay, :challenge_category]
      argument :manager_id, :uuid
      argument :reward_id, :uuid
      argument :reward_first_id, :uuid
      argument :reward_second_id, :uuid
      argument :reward_third_id, :uuid
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :user_domain, :period, :start_date, :end_date, :reward_failure, :reward_realtime, :visibility_mode, :report_message_frequency, :remind_update_delay, :challenge_category]
      argument :manager_id, :uuid
      argument :reward_id, :uuid
      argument :reward_first_id, :uuid
      argument :reward_second_id, :uuid
      argument :reward_third_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_start do
      description "启动挑战（draft -> inprogress）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以启动"
      change set_attribute(:state, :inprogress)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_check do
      description "检查挑战进度并触发奖励评估"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_done do
      description "完成挑战（inprogress -> done）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :inprogress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :inprogress}))
        end
      end
      # message: "只有进行中状态可以完成"
      change set_attribute(:state, :done)
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
