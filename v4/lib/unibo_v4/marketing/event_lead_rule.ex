# Workflow: event_lead_rule_maintain_flow — 活动线索规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.EventLeadRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_event_lead_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_event_lead_rule

    queries do
      get :get_marketing_event_lead_rule, :read
      list :list_marketing_event_lead_rules, :read
    end

    mutations do
      create :create_marketing_event_lead_rule, :create
      update :update_marketing_event_lead_rule, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :lead_creation_basis, :atom do
      constraints one_of: [:attendee, :order]
      default :attendee
      public? true
    end
    attribute :lead_creation_trigger, :atom do
      constraints one_of: [:create, :confirm, :done]
      default :create
      public? true
    end
    attribute :lead_type, :atom do
      constraints one_of: [:lead, :opportunity]
      default :lead
      public? true
    end
    attribute :event_registration_filter, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Marketing.Event do
      public? true
    end
    belongs_to :company, UniboV4.Marketing.Company do
      public? true
    end
    belongs_to :lead_user, UniboV4.Marketing.User do
      public? true
    end
    has_many :event_type_rules, UniboV4.Marketing.EventLeadRuleEventType do
      public? true
      destination_attribute :event_lead_rule_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :active, :lead_creation_basis, :lead_creation_trigger, :lead_type, :event_registration_filter]
      argument :event_id, :uuid
      argument :company_id, :uuid
      argument :lead_user_id, :uuid
      validate present(:name)
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
      accept [:name, :active, :lead_creation_basis, :lead_creation_trigger, :lead_type, :event_registration_filter]
      argument :event_id, :uuid
      argument :company_id, :uuid
      argument :lead_user_id, :uuid
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
    action :run_on_registrations do
      argument :registration_ids, :string, allow_nil?: false
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
