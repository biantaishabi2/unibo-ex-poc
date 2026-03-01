defmodule UniboV4.CRM.SalesTeamMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_sales_team_members"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_sales_team_member

    queries do
      get :get_crm_sales_team_member, :read
      list :list_crm_sales_team_members, :read
    end

    mutations do
      create :create_crm_sales_team_member, :create
      update :update_crm_sales_team_member, :update
      destroy :delete_crm_sales_team_member, :destroy
    end

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
