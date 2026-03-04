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
defmodule UniboV4.Sign.SignRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Sign.SignRequest.Notifier]

  postgres do
    table "sign_requests"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :reference, :string, public?: true
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :sent, :signed, :canceled, :expired]
      default :draft
      public? true
    end
    attribute :signing_order, :boolean do
      default false
      public? true
    end
    attribute :message, :string, public?: true
    attribute :completed_document, :string, public?: true
    attribute :validity_days, :integer, public?: true
    attribute :expires_at, :utc_datetime, public?: true
    attribute :access_token, :string, public?: true
    attribute :reminder_enabled, :boolean do
      default true
      public? true
    end
    attribute :last_reminder_at, :utc_datetime, public?: true
    attribute :completion_date, :utc_datetime, public?: true
    attribute :ip_address, :string, public?: true
    attribute :res_model, :string, public?: true
    attribute :res_id, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :template, UniboV4.Sign.SignTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :requester, UniboV4.Sign.User do
      public? true
      allow_nil? false
    end
    has_many :request_items, UniboV4.Sign.SignRequestItem do
      public? true
      destination_attribute :request_id
    end
    has_many :logs, UniboV4.Sign.SignLog do
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
      # skipped: validate compare :request_items (incompatible with bulk update atomic path)
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
    update :cancel do
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
    update :recall do
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
    update :expire do
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
    update :complete do
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
      # TODO: 跨实体聚合表达式暂不支持
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
    identity :unique_access_token, [:access_token]
  end

end
