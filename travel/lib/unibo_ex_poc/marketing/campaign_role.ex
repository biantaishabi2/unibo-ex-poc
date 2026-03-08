# Workflow: campaign_role_manage_flow — 活动角色管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Marketing.CampaignRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "营销活动角色"
  end

  postgres do
    table "marketing_campaign_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_campaign_role

    queries do
      get :get_marketing_campaign_role, :read
      list :list_marketing_campaign_roles, :read
    end

    mutations do
      create :create_marketing_campaign_role, :create
      destroy :delete_marketing_campaign_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
      description "角色（如 manager、coordinator）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :campaign, UniboExPoc.Marketing.Campaign do
      public? true
      allow_nil? false
    end
    belongs_to :person, UniboExPoc.Marketing.Party do
      public? true
      allow_nil? false
      source_attribute :person_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:role]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :person_id, :uuid, allow_nil?: false
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      change manage_relationship(:person_id, :person, type: :append, on_lookup: :relate)
      validate present(:role)
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
