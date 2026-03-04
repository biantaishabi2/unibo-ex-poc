defmodule UniboV4.CRM.SalesTeamMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "crm_sales_team_members"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboV4.CRM.SalesTeam do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.CRM.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:active]
      argument :team_id, :uuid, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:team_id, :team, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 relationship_required
      # TODO: 不支持的 action 内校验规则 relationship_required
      # TODO: 不支持的 action 内校验规则 belongs_to_exists
      # TODO: 不支持的 change effect custom
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
      accept [:active]
      # skipped: validate belongs_to_exists :team_id (incompatible with bulk update atomic path)
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
