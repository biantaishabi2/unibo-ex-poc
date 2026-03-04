# Workflow: karma_tracking_record_flow — Karma变更记录写入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Gamification.KarmaTracking do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_karma_trackings"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :old_value, :integer, public?: true
    attribute :new_value, :integer do
      allow_nil? false
      public? true
    end
    attribute :consolidated, :boolean do
      default false
      public? true
    end
    attribute :tracking_date, :utc_datetime do
      default &DateTime.utc_now/0
      public? true
    end
    attribute :reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :gain
  end

  relationships do
    belongs_to :user, UniboV4.Gamification.ResUser do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:old_value, :new_value, :consolidated, :tracking_date, :reason]
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:new_value)
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

end
