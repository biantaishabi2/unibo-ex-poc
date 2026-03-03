# Workflow: utm_tag_maintain_flow — UTM 标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.UtmTag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_utm_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_utm_tag

    queries do
      get :get_marketing_utm_tag, :read
      list :list_marketing_utm_tags, :read
    end

    mutations do
      create :create_marketing_utm_tag, :create
      update :update_marketing_utm_tag, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :campaigns, UniboV4.Marketing.UtmCampaign do
      public? true
      through UniboV4.Marketing.UtmCampaignTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :color]
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
      accept [:name, :color]
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
    identity :unique_utm_tag_name, [:name]
  end

end
