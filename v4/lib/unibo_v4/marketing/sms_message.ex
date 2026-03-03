# Workflow: sms_message_lifecycle — 短信消息生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> send
#   create --> cancel
#   send --> resend_failed
#   cancel --> [*]
#   resend_failed --> [*]
# ```
defmodule UniboV4.Marketing.SmsMessage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Marketing.SmsMessage.Notifier]

  postgres do
    table "marketing_sms_messages"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_sms_message

    queries do
      get :get_marketing_sms_message, :read
      list :list_marketing_sms_messages, :read
    end

    mutations do
      create :create_marketing_sms_message, :create
      update :send_marketing_sms_message, :send
      update :cancel_marketing_sms_message, :cancel
      update :resend_failed_marketing_sms_message, :resend_failed
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :uuid, :string do
      allow_nil? false
      public? true
    end
    attribute :number, :string do
      allow_nil? false
      public? true
    end
    attribute :body, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:outgoing, :process, :pending, :sent, :error, :canceled]
      default :outgoing
      public? true
    end
    attribute :failure_type, :atom do
      constraints one_of: [:sms_number_missing, :sms_number_format, :sms_country_not_supported, :sms_credit, :sms_server, :sms_acc, :sms_blacklist, :sms_duplicate, :sms_optout, :sms_registration_needed, :sms_invalid_destination, :sms_not_allowed, :sms_rejected, :unknown]
      public? true
    end
    attribute :to_delete, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :partner, UniboV4.Marketing.Contact do
      public? true
    end
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:uuid, :number, :body]
      argument :partner_id, :uuid
      argument :campaign_id, :uuid
      validate present(:number)
      validate present(:body)
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
      primary? true
      accept []
      # skipped: validate present :number (incompatible with bulk update atomic path)
      # skipped: validate present :body (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :outgoing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :outgoing}))
        end
      end
      # message: "只有待发送状态可以发送"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :process)
      # TODO: 不支持的 change effect custom
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
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :outgoing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :outgoing}))
        end
      end
      # message: "只有待发送状态可以取消"
      change set_attribute(:status, :canceled)
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
    update :resend_failed do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :error do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :error}))
        end
      end
      # message: "只有错误状态可以重试"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :outgoing)
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

end
