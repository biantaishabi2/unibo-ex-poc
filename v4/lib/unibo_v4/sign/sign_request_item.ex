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
defmodule UniboV4.Sign.SignRequestItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sign_request_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :signing_order, :integer, public?: true
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :sent, :completed, :refused]
      default :draft
      public? true
    end
    attribute :access_token, :string, public?: true
    attribute :signer_email, :string, public?: true
    attribute :signed_at, :utc_datetime, public?: true
    attribute :refuse_reason, :string, public?: true
    attribute :signer_ip, :string, public?: true
    attribute :latitude, :float, public?: true
    attribute :longitude, :float, public?: true
    attribute :sms_number, :string, public?: true
    attribute :sms_token, :string, public?: true
  end

  relationships do
    belongs_to :request, UniboV4.Sign.SignRequest do
      public? true
      allow_nil? false
    end
    belongs_to :role, UniboV4.Sign.SignRole do
      public? true
      allow_nil? false
    end
    belongs_to :signer, UniboV4.Sign.User do
      public? true
    end
  end

  actions do
    create :create do
      primary? true
      accept [:signing_order, :signer_email, :sms_number]
      argument :request_id, :uuid, allow_nil?: false
      argument :role_id, :uuid, allow_nil?: false
      argument :signer_id, :uuid
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
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
    update :send do
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
    update :sign do
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
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的表达式类型
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
    update :refuse do
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
      # TODO: 不支持的表达式类型
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
    update :reset do
      accept []
      # TODO: 跨实体聚合表达式暂不支持
      change set_attribute(:state, :draft)
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
    identity :unique_item_access_token, [:access_token]
  end

end
