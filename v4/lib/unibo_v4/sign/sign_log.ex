# Workflow: sign_log_audit_flow — 审计日志创建与读取流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   read --> [*]
# ```
defmodule UniboV4.Sign.SignLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sign_logs"
    repo UniboV4.Repo
  end

  graphql do
    type :sign_sign_log

    queries do
      get :get_sign_sign_log, :read
      list :list_sign_sign_logs, :read
    end

    mutations do
      create :create_sign_sign_log, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :action, :atom do
      allow_nil? false
      constraints one_of: [:created, :sent, :open, :sign, :refuse, :update, :reassign, :recall, :reminded, :canceled]
      public? true
    end
    attribute :ip_address, :string, public?: true
    attribute :user_agent, :string, public?: true
    attribute :log_hash, :string do
      allow_nil? false
      public? true
    end
    attribute :timestamp, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :note, :string, public?: true
    attribute :metadata, :string, public?: true
  end

  relationships do
    belongs_to :request, UniboV4.Sign.SignRequest do
      public? true
      allow_nil? false
    end
    belongs_to :request_item, UniboV4.Sign.SignRequestItem do
      public? true
    end
    belongs_to :actor, UniboV4.Sign.User do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:action, :ip_address, :user_agent, :note, :metadata]
      argument :request_id, :uuid, allow_nil?: false
      argument :request_item_id, :uuid
      argument :actor_id, :uuid
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
      validate present(:action)
      validate present(:timestamp)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
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

end
