# Workflow: campaign_role_manage_flow — 活动角色管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Marketing.CampaignRole do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_campaign_roles"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      public? true
      allow_nil? false
    end
    belongs_to :person, UniboV4.Marketing.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
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

end
