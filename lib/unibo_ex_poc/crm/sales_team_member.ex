defmodule UniboExPoc.CRM.SalesTeamMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "销售团队成员关联，支持单/多团队模式下的成员归属管理"
  end

  postgres do
    table "crm_sales_team_members"
    repo UniboExPoc.Repo
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
      description "活跃状态，单团队模式下自动归档其他成员资格"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :team, UniboExPoc.CRM.SalesTeam do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.CRM.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
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
      validate present(:team_id)
      validate present(:user_id)
      validate present(:team_id)
      change UniboExPoc.CRM.Changes.SalesTeamMember.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:active]
      # skipped: validate relationship_required :team_id (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
