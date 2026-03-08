# Workflow: sign_request_item_write_flow — 签署方写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   send --> [*]
#   sign --> [*]
#   refuse --> [*]
#   reset --> [*]
# ```
defmodule UniboExPoc.Sign.SignRequestItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "签名请求中的单个签署方，每人持有独立的访问令牌"
  end

  postgres do
    table "sign_request_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_sign_request_item

    mutations do
      create :create_sign_sign_request_item, :create
      update :send_sign_sign_request_item, :send
      update :sign_sign_sign_request_item, :sign
      update :refuse_sign_sign_request_item, :refuse
      update :reset_sign_sign_request_item, :reset
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :signing_order, :integer do
      public? true
      description "签名顺序号（1, 2, 3...），顺序签名时使用"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :sent, :completed, :refused]
      default :draft
      public? true
      description "单个签署方状态"
    end
    attribute :access_token, :string do
      public? true
      description "每人独立的访问令牌（UUID）"
    end
    attribute :signer_email, :string do
      public? true
      description "签名人邮箱（外部签名人使用）"
    end
    attribute :signed_at, :utc_datetime do
      public? true
      description "签名完成时间"
    end
    attribute :refuse_reason, :string do
      public? true
      description "拒签原因"
    end
    attribute :signer_ip, :string do
      public? true
      description "签名时 IP 地址"
    end
    attribute :latitude, :float do
      public? true
      description "签署时纬度（可选，GPS 定位）"
    end
    attribute :longitude, :float do
      public? true
      description "签署时经度（可选，GPS 定位）"
    end
    attribute :sms_number, :string do
      public? true
      description "短信验证手机号（二次认证）"
    end
    attribute :sms_token, :string do
      public? true
      description "短信验证码，有效期 10 分钟"
    end
  end

  relationships do
    belongs_to :request, UniboExPoc.Sign.SignRequest do
      public? true
      allow_nil? false
    end
    belongs_to :role, UniboExPoc.Sign.SignRole do
      public? true
      allow_nil? false
    end
    belongs_to :signer, UniboExPoc.Sign.Party do
      public? true
      source_attribute :signer_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:signing_order, :signer_email, :sms_number]
      argument :request_id, :uuid, allow_nil?: false
      argument :role_id, :uuid, allow_nil?: false
      argument :signer_id, :uuid
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
      change UniboExPoc.Sign.Changes.SignRequestItem.ComputeAccessToken
      change set_attribute(:id, expr(id))
    end
    update :send do
      description "随 SignRequest 发送（状态 draft → sent）"
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
      change set_attribute(:state, :sent)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :sign do
      description "签署完成"
      accept []
      argument :signer_ip, :string
      argument :latitude, :float
      argument :longitude, :float
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以签署"
      change set_attribute(:state, :completed)
      change UniboExPoc.Sign.Changes.SignRequestItem.ComputeSignedAt
      change set_attribute(:signer_ip, expr(^arg(:signer_ip)))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :refuse do
      description "拒签"
      argument :refuse_reason, :string, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以拒签"
      change set_attribute(:state, :refused)
      change set_attribute(:refuse_reason, expr(^arg(:refuse_reason)))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reset do
      description "重置为草稿（随 SignRequest 撤回时触发，重新生成 token）"
      accept []
      change UniboExPoc.Sign.Changes.SignRequestItem.ComputeAccessToken
      change set_attribute(:state, :draft)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_item_access_token, [:access_token]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
