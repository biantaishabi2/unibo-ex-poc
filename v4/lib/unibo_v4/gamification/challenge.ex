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
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Gamification.Challenge.Notifier]

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
    end
    attribute :description, :string, public?: true
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :inprogress, :done]
      default :draft
      public? true
    end
    attribute :user_domain, :string, public?: true
    attribute :period, :atom do
      constraints one_of: [:once, :daily, :weekly, :monthly, :yearly]
      default :once
      public? true
    end
    attribute :start_date, :date, public?: true
    attribute :end_date, :date, public?: true
    attribute :reward_failure, :boolean do
      default false
      public? true
    end
    attribute :reward_realtime, :boolean do
      default true
      public? true
    end
    attribute :visibility_mode, :atom do
      constraints one_of: [:personal, :ranking]
      default :personal
      public? true
    end
    attribute :report_message_frequency, :atom do
      constraints one_of: [:never, :onchange, :daily, :weekly, :monthly, :yearly]
      default :never
      public? true
    end
    attribute :remind_update_delay, :integer, public?: true
    attribute :last_report_date, :date, public?: true
    attribute :challenge_category, :atom do
      constraints one_of: [:hr, :other]
      default :other
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :user_count
    # TODO: 不支持的 calculation 表达式 :next_report_date
  end

  relationships do
    belongs_to :manager, UniboV4.Gamification.ResUser do
      public? true
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
    many_to_many :user_ids, UniboV4.Gamification.ResUser do
      public? true
      through UniboV4.Gamification.ChallengeUserLink
    end
    many_to_many :invited_user_ids, UniboV4.Gamification.ResUser do
      public? true
      through UniboV4.Gamification.ChallengeInvitedUserLink
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
      accept [:name, :description, :user_domain, :period, :start_date, :end_date, :reward_failure, :reward_realtime, :visibility_mode, :report_message_frequency, :remind_update_delay, :challenge_category]
      argument :manager_id, :uuid
      argument :reward_id, :uuid
      argument :reward_first_id, :uuid
      argument :reward_second_id, :uuid
      argument :reward_third_id, :uuid
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
    update :action_check do
      accept []
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
    update :action_done do
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
