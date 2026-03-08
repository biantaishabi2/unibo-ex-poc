# Workflow: sign_flow — 签名全流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> send
#   create --> cancel
#   send --> complete
#   send --> cancel
#   send --> recall
#   send --> expire
#   complete --> [*] : completed
#   cancel --> [*] : canceled
#   recall --> send
#   recall --> cancel
#   expire --> [*] : expired
# ```
defmodule UniboExPoc.Sign.SignRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Sign.SignRequest.Notifier]

  resource do
    description "签名请求，发起人基于模板创建并发送给签署方"
  end

  postgres do
    table "sign_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_sign_request

    queries do
      get :get_sign_sign_request, :read
      list :list_sign_sign_requests, :read
    end

    mutations do
      create :create_sign_sign_request, :create
      update :send_sign_sign_request, :send
      update :cancel_sign_sign_request, :cancel
      update :recall_sign_sign_request, :recall
      update :expire_sign_sign_request, :expire
      update :complete_sign_sign_request, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :reference, :string do
      public? true
      description "请求名称/编号"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :sent, :signed, :canceled, :expired]
      default :draft
      public? true
      description "请求状态"
    end
    attribute :signing_order, :boolean do
      default false
      public? true
      description "是否启用顺序签名"
    end
    attribute :message, :string do
      public? true
      description "发送给签名人的附言"
    end
    attribute :completed_document, :string do
      public? true
      description "签名完成后的最终 PDF"
    end
    attribute :validity_days, :integer do
      public? true
      description "签名请求有效天数"
    end
    attribute :expires_at, :utc_datetime do
      public? true
      description "过期时间"
    end
    attribute :access_token, :string do
      public? true
      description "门户访问令牌（UUID），创建时自动生成"
    end
    attribute :reminder_enabled, :boolean do
      default true
      public? true
      description "是否启用自动提醒"
    end
    attribute :last_reminder_at, :utc_datetime do
      public? true
      description "上次提醒时间"
    end
    attribute :completion_date, :utc_datetime do
      public? true
      description "全部签署完成的时间"
    end
    attribute :ip_address, :string do
      public? true
      description "发起人创建请求时的 IP 地址"
    end
    attribute :res_model, :string do
      public? true
      description "来源模块名称（跨模块回调用）"
    end
    attribute :res_id, :integer do
      public? true
      description "来源记录 ID"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :template, UniboExPoc.Sign.SignTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :requester, UniboExPoc.Sign.Party do
      public? true
      allow_nil? false
      source_attribute :requester_party_id
    end
    has_many :request_items, UniboExPoc.Sign.SignRequestItem do
      public? true
      destination_attribute :request_id
    end
    has_many :logs, UniboExPoc.Sign.SignLog do
      public? true
      destination_attribute :request_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:reference, :signing_order, :message, :validity_days, :reminder_enabled, :res_model, :res_id]
      argument :template_id, :uuid, allow_nil?: false
      argument :request_items, {:array, :string}, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      argument :requester_id, :uuid, allow_nil?: false
      change manage_relationship(:requester_id, :requester, type: :append, on_lookup: :relate)
      change manage_relationship(:request_items, :request_items, type: :create)
      change relate_actor(:requester)
      change UniboExPoc.Sign.Changes.SignRequest.ComputeAccessToken
      change UniboExPoc.Sign.Changes.SignRequest.ComputeExpiresAt
      change set_attribute(:id, expr(id))
    end
    update :send do
      description "发送签名请求给签署方"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送"
      # skipped: validate compare :request_items (incompatible with bulk update atomic path)
      change set_attribute(:state, :sent)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消签名请求"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :sent] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :sent]}))
        end
      end
      # message: "只有草稿或已发送状态可以取消"
      change set_attribute(:state, :canceled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :recall do
      description "撤回已发送的请求（重置所有 item 为 draft，使旧 token 失效）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以撤回"
      change set_attribute(:state, :draft)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :expire do
      description "过期处理（系统 cron 自动触发）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以过期"
      change set_attribute(:state, :expired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "标记签署完成（所有签署方均已完成时自动触发）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以完成"
      change set_attribute(:state, :signed)
      change UniboExPoc.Sign.Changes.SignRequest.ComputeCompletionDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_access_token, [:access_token]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
