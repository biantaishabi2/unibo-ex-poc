# Workflow: team_management — 服务团队管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Helpdesk.HelpdeskTeam do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_teams"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :alias_email, :string, public?: true
    attribute :assignment_method, :atom do
      allow_nil? false
      constraints one_of: [:manual, :random, :balanced]
      default :manual
      public? true
    end
    attribute :auto_assignment, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :color, :integer do
      allow_nil? false
      default 0
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :use_sla, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_website_form, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_customer_portal, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_timesheet, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_field_service, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_customer_rating, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :use_knowledge_base, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :resource_calendar_id, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tickets, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      destination_attribute :team_id
    end
    has_many :sla_policies, UniboV4.Helpdesk.HelpdeskSLA do
      public? true
      destination_attribute :team_id
    end
    many_to_many :members, UniboV4.Helpdesk.Employee do
      public? true
      through UniboV4.Helpdesk.HelpdeskTeamMemberLink
    end
    many_to_many :stage_ids, UniboV4.Helpdesk.HelpdeskStage do
      public? true
      through UniboV4.Helpdesk.HelpdeskTeamStageLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :alias_email, :assignment_method, :auto_assignment, :use_sla, :use_website_form, :use_customer_portal, :use_timesheet, :use_field_service, :use_customer_rating, :use_knowledge_base, :resource_calendar_id]
      validate present(:name)
      # message: "团队名称必填"
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
      accept [:name, :description, :alias_email, :assignment_method, :auto_assignment, :active, :use_sla, :use_website_form, :use_customer_portal, :use_timesheet, :use_field_service, :use_customer_rating, :use_knowledge_base, :resource_calendar_id]
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
    identity :unique_team_name, [:name]
  end

end
