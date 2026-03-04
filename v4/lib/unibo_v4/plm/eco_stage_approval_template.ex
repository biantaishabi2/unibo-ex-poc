# Workflow: eco_approval_template_maintain_flow — 审批模板维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.PLM.EcoStageApprovalTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "plm_eco_stage_approval_templates"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
    end
    attribute :approver_id, :uuid, public?: true
    attribute :approval_type, :atom do
      constraints one_of: [:required, :optional, :comment]
      default :required
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :stage, UniboV4.PLM.EcoStage do
      public? true
      allow_nil? false
    end
  end

  actions do
    create :create do
      primary? true
      accept [:role, :approver_id, :approval_type]
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
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
    update :update do
      primary? true
      accept [:role, :approver_id, :approval_type]
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
