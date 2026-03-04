# Workflow: sla_policy_management — SLA 策略管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Helpdesk.HelpdeskSLA do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_slas"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :time_days, :integer do
      allow_nil? false
      default 0
      public? true
    end
    attribute :time_hours, :decimal do
      allow_nil? false
      default 0.0
      public? true
    end
    attribute :minimum_priority, :atom do
      constraints one_of: [:low, :normal, :high, :urgent]
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboV4.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
    end
    belongs_to :reach_stage, UniboV4.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
    end
    belongs_to :ticket_type, UniboV4.Helpdesk.HelpdeskTicketType do
      public? true
    end
    many_to_many :tag_ids, UniboV4.Helpdesk.HelpdeskTag do
      public? true
      through UniboV4.Helpdesk.HelpdeskSLATagLink
    end
    many_to_many :partner_ids, UniboV4.Helpdesk.Partner do
      public? true
      through UniboV4.Helpdesk.HelpdeskSLAPartnerLink
    end
    many_to_many :exclude_stage_ids, UniboV4.Helpdesk.HelpdeskStage do
      public? true
      through UniboV4.Helpdesk.HelpdeskSLAExcludeStageLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :time_days, :time_hours, :minimum_priority]
      argument :team_id, :uuid, allow_nil?: false
      argument :reach_stage_id, :uuid, allow_nil?: false
      argument :ticket_type_id, :uuid
      change manage_relationship(:team_id, :team, type: :append, on_lookup: :relate)
      change manage_relationship(:reach_stage_id, :reach_stage, type: :append, on_lookup: :relate)
      validate present(:name)
      # message: "策略名称必填"
      validate present(:team)
      # message: "必须指定所属团队"
      validate present(:reach_stage)
      # message: "必须指定目标阶段"
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:name, :time_days, :time_hours, :minimum_priority, :active]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    identity :unique_sla_name_team, [:name, :team_id]
  end

end
