defmodule UniboV4.Marketing.EventLeadRuleEventType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "线索规则-活动类别桥接实体"
  end

  postgres do
    table "marketing_event_lead_rule_event_types"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_event_lead_rule_event_type

    queries do
      get :get_marketing_event_lead_rule_event_type, :read
      list :list_marketing_event_lead_rule_event_types, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :event_type_id, :uuid do
      allow_nil? false
      public? true
      description "活动类别 ID（字符串标识，不作为关系建模）"
    end
  end

  relationships do
    belongs_to :rule, UniboV4.Marketing.EventLeadRule do
      public? true
      allow_nil? false
      source_attribute :event_lead_rule_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
