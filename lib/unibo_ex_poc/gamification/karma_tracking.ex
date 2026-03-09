# Workflow: karma_tracking_record_flow — Karma变更记录写入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Gamification.KarmaTracking do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "Karma变更追踪记录，支持定期合并历史记录防止表膨胀"
  end

  postgres do
    table "gamification_karma_trackings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_karma_tracking

    queries do
      get :get_gamification_karma_tracking, :read
      list :list_gamification_karma_trackings, :read
    end

    mutations do
      create :create_gamification_karma_tracking, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :old_value, :integer do
      public? true
      description "变更前karma值"
    end
    attribute :new_value, :integer do
      allow_nil? false
      public? true
      description "变更后karma值"
    end
    attribute :consolidated, :boolean do
      default false
      public? true
      description "是否已合并"
    end
    attribute :tracking_date, :utc_datetime do
      default &DateTime.utc_now/0
      public? true
      description "跟踪日期"
    end
    attribute :reason, :string do
      public? true
      description "变更原因"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :gain, :integer, expr((new_value - old_value))
  end

  relationships do
    belongs_to :user, UniboExPoc.Gamification.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:old_value, :new_value, :consolidated, :tracking_date, :reason]
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:new_value)
      change set_attribute(:id, expr(id))
    end
  end

end
