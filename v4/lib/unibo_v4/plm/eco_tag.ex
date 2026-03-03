# Workflow: eco_tag_creation_flow — ECO 标签创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.PLM.EcoTag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "plm_eco_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco_tag

    queries do
      get :get_plm_eco_tag, :read
      list :list_plm_eco_tags, :read
    end

    mutations do
      create :create_plm_eco_tag, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update]
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
  end

  identities do
    identity :unique_eco_tag_name, [:name]
  end

end
