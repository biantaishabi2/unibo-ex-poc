# Workflow: eco_stage_maintain_flow — ECO 阶段维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.PLM.EcoStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "plm_eco_stages"
    repo UniboV4.Repo
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
    attribute :folded, :boolean do
      default false
      public? true
    end
    attribute :allow_apply, :boolean do
      default false
      public? true
    end
    attribute :is_final, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :type_ids, UniboV4.PLM.EcoType do
      public? true
      through UniboV4.PLM.EcoTypeStageLink
    end
    has_many :approval_template_ids, UniboV4.PLM.EcoStageApprovalTemplate do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :folded, :allow_apply, :is_final]
      argument :approval_template_ids, {:array, :map}, default: []
      change manage_relationship(:approval_template_ids, :approval_template_ids, type: :create)
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
      accept [:name, :sequence, :folded, :allow_apply, :is_final]
      argument :approval_template_ids, {:array, :map}, default: []
      change manage_relationship(:approval_template_ids, :approval_template_ids, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
    identity :unique_eco_stage_name, [:name]
  end

end
