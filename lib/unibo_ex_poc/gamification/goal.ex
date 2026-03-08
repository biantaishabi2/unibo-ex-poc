# Workflow: goal_flow — 目标生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> action_start
#   update --> update
#   update --> action_start
#   update --> action_cancel
#   action_start --> action_reach
#   action_start --> action_fail
#   action_start --> action_cancel
#   action_reach --> [*] : reached
#   action_fail --> [*] : failed
#   action_cancel --> [*]
# ```
defmodule UniboV4.Gamification.Goal do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Gamification.Goal.Notifier]

  resource do
    description "目标实例，记录用户在特定时间段的目标进度和状态"
  end

  postgres do
    table "gamification_goals"
    repo UniboV4.Repo
  end

  graphql do
    type :gamification_goal

    queries do
      get :get_gamification_goal, :read
      list :list_gamification_goals, :read
    end

    mutations do
      create :create_gamification_goal, :create
      update :update_gamification_goal, :update
      update :action_start_gamification_goal, :action_start
      update :action_reach_gamification_goal, :action_reach
      update :action_fail_gamification_goal, :action_fail
      update :action_cancel_gamification_goal, :action_cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :start_date, :date do
      public? true
      description "开始日期"
    end
    attribute :end_date, :date do
      public? true
      description "结束日期"
    end
    attribute :target_goal, :float do
      allow_nil? false
      public? true
      description "目标值"
    end
    attribute :current, :float do
      allow_nil? false
      default 0
      public? true
      description "当前值"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :inprogress, :reached, :failed, :canceled]
      default :draft
      public? true
      description "目标状态"
    end
    attribute :to_update, :boolean do
      default false
      public? true
      description "需要更新标记"
    end
    attribute :closed, :boolean do
      default false
      public? true
      description "是否已关闭"
    end
    attribute :remind_update_delay, :integer do
      public? true
      description "手动目标提醒延迟天数"
    end
    attribute :last_update, :date do
      public? true
      description "最后更新日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :completeness, :float, expr(((current / target_goal) * 100))
  end

  relationships do
    belongs_to :definition, UniboV4.Gamification.GoalDefinition do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Gamification.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :line, UniboV4.Gamification.ChallengeLine do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:start_date, :end_date, :target_goal, :current, :state, :remind_update_delay]
      argument :definition_id, :uuid, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false
      argument :line_id, :uuid
      change manage_relationship(:definition_id, :definition, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:target_goal)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:current, :state, :to_update, :closed, :last_update, :remind_update_delay]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_start do
      description "启动目标（draft -> inprogress）"
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
    update :action_reach do
      description "标记达成（inprogress -> reached）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :inprogress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :inprogress}))
        end
      end
      # message: "只有进行中状态可以标记达成"
      change set_attribute(:state, :reached)
      change set_attribute(:closed, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_fail do
      description "标记失败（inprogress -> failed）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :inprogress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :inprogress}))
        end
      end
      # message: "只有进行中状态可以标记失败"
      change set_attribute(:state, :failed)
      change set_attribute(:closed, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_cancel do
      description "取消目标（任意状态 -> canceled）"
      accept []
      change set_attribute(:state, :canceled)
      change set_attribute(:closed, true)
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
