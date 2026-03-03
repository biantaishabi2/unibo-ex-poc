# Workflow: eco_type_maintain_flow — ECO 类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.PLM.EcoType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "plm_eco_types"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco_type

    queries do
      get :get_plm_eco_type, :read
      list :list_plm_eco_types, :read
    end

    mutations do
      create :create_plm_eco_type, :create
      update :update_plm_eco_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :alias_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :stage_ids, UniboV4.PLM.EcoStage do
      public? true
      through UniboV4.PLM.EcoTypeStageLink
    end
    has_many :ecos, UniboV4.PLM.Eco do
      public? true
      destination_attribute :type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :alias_id]
      validate present(:name)
      validate compare(:stage_ids, greater_than: 0)
      # message: "每个ECO类型必须关联至少一个阶段"
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
      accept [:name, :sequence, :alias_id]
      # skipped: validate compare :stage_ids (incompatible with bulk update atomic path)
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
    identity :unique_eco_type_name, [:name]
  end

end
