# Workflow: utm_campaign_maintain_flow — UTM 活动维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.UtmCampaign do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_utm_campaigns"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :is_auto_campaign, :boolean do
      default false
      public? true
    end
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :stage, UniboV4.Marketing.UtmStage do
      public? true
    end
    belongs_to :responsible, UniboV4.Marketing.User do
      public? true
    end
    many_to_many :tags, UniboV4.Marketing.UtmTag do
      public? true
      through UniboV4.Marketing.UtmCampaignTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :title, :is_auto_campaign, :color, :active]
      argument :stage_id, :uuid
      argument :responsible_id, :uuid
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
      accept [:name, :title, :is_auto_campaign, :color, :active]
      argument :stage_id, :uuid
      argument :responsible_id, :uuid
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

  identities do
    identity :unique_utm_campaign_name, [:name]
  end

end
