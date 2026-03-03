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
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Gamification.Goal.Notifier]

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
    attribute :start_date, :date, public?: true
    attribute :end_date, :date, public?: true
    attribute :target_goal, :float do
      allow_nil? false
      public? true
    end
    attribute :current, :float do
      allow_nil? false
      default 0
      public? true
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :inprogress, :reached, :failed, :canceled]
      default :draft
      public? true
    end
    attribute :to_update, :boolean do
      default false
      public? true
    end
    attribute :closed, :boolean do
      default false
      public? true
    end
    attribute :remind_update_delay, :integer, public?: true
    attribute :last_update, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :completeness
  end

  relationships do
    belongs_to :definition, UniboV4.Gamification.GoalDefinition do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Gamification.ResUser do
      public? true
      allow_nil? false
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
      accept [:current, :state, :to_update, :closed, :last_update, :remind_update_delay]
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
    update :action_start do
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
    update :action_reach do
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
    update :action_fail do
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
    update :action_cancel do
      accept []
      change set_attribute(:state, :canceled)
      change set_attribute(:closed, true)
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
