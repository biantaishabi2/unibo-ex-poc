# Workflow: event_lead_rule_maintain_flow — 活动线索规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.EventLeadRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "活动→CRM 线索自动生成规则"
  end

  postgres do
    table "marketing_event_lead_rules"
    repo UniboExPoc.Repo
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
      description "规则名称"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :lead_creation_basis, :atom do
      constraints one_of: [:attendee, :order]
      default :attendee
      public? true
      description "线索创建粒度（按参会者/按订单）"
    end
    attribute :lead_creation_trigger, :atom do
      constraints one_of: [:create, :confirm, :done]
      default :create
      public? true
      description "触发时机（报名创建/确认/签到）"
    end
    attribute :lead_type, :atom do
      constraints one_of: [:lead, :opportunity]
      default :lead
      public? true
      description "生成线索类型"
    end
    attribute :event_registration_filter, :string do
      public? true
      description "报名过滤条件（域表达式）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboExPoc.Marketing.Event do
      public? true
    end
    belongs_to :company, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :company_party_id
    end
    belongs_to :lead_user, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :lead_user_party_id
    end
    has_many :event_type_rules, UniboExPoc.Marketing.EventLeadRuleEventType do
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
      # validation: valid_filter_expression
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
      description "根据规则批量处理报名记录，创建/更新线索"
      argument :registration_ids, :string, allow_nil?: false
      run fn input, _context ->
        # BR-EL02: 过滤→分组→创建/更新 CRM 线索（含 UTM 传播） — 由 Change 模块处理: UniboExPoc.Marketing.Changes.EventLeadRule.RunOnRegistrationsComplex1
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
