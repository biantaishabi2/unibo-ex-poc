defmodule UniboExPoc.Travel.TravelPolicyCheck do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "差标校验记录，记录订单下单时针对差旅政策的校验结果、超标金额与处理策略"
  end

  postgres do
    table "travel_policy_checks"
    repo UniboExPoc.Repo
    identity_index_names unique_order: "idx_travel_policy_checks_unique_order"
  end

  graphql do
    type :travel_travel_policy_check

    queries do
      get :get_travel_travel_policy_check, :read
      list :list_travel_travel_policy_checks, :read
    end

    mutations do
      create :create_travel_travel_policy_check, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :check_result, :atom do
      allow_nil? false
      constraints one_of: [:compliant, :exceeded, :blocked]
      public? true
      description "校验结果"
    end
    attribute :policy_amount, :integer do
      public? true
      description "差标金额（单位分）"
    end
    attribute :actual_amount, :integer do
      public? true
      description "实际金额（单位分）"
    end
    attribute :exceed_amount, :integer do
      public? true
      description "超标金额"
    end
    attribute :exceed_ratio, :string do
      public? true
      description "超标比例（如\"15%\"）"
    end
    attribute :exceed_strategy, :string do
      public? true
      description "命中的超标策略"
    end
    attribute :exceed_reason, :string do
      public? true
      description "超标原因（员工填写）"
    end
    attribute :personal_pay_amount, :integer do
      public? true
      description "个人支付部分"
    end
    attribute :approval_request_id, :string do
      public? true
      description "审批请求ID（不做跨域外键）"
    end
    attribute :approval_mode, :atom do
      constraints one_of: [:none, :self, :oa]
      default :self
      public? true
      description "命中政策时的审批模式快照"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboExPoc.Travel.TravelOrder do
      public? true
      allow_nil? false
    end
    belongs_to :policy, UniboExPoc.Travel.TravelPolicy do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      description "Create Travel Policy Check via Create. doc_url: graphql://contract/travel/create_travel_travel_policy_check"
      primary? true
      accept [:order_id, :policy_id, :check_result, :policy_amount, :actual_amount, :exceed_amount, :exceed_ratio, :exceed_strategy, :exceed_reason, :personal_pay_amount, :approval_request_id, :approval_mode]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :policy_id, :uuid, allow_nil?: false
      change manage_relationship(:policy_id, :policy, type: :append, on_lookup: :relate)
      validate present(:order_id)
      validate present(:policy_id)
      validate present(:check_result)
    end
  end

  identities do
    identity :unique_order, [:order_id]
  end

end
