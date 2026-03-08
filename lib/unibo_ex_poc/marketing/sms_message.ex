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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Marketing.SmsMessage.Notifier]

  resource do
    description "短信消息"
  end

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
      description "IAP 追踪唯一标识"
    end
    attribute :number, :string do
      allow_nil? false
      public? true
      description "收件人手机号"
    end
    attribute :body, :string do
      allow_nil? false
      public? true
      description "短信内容"
    end
    attribute :status, :atom do
      constraints one_of: [:outgoing, :process, :pending, :sent, :error, :canceled]
      default :outgoing
      public? true
    end
    attribute :failure_type, :atom do
      constraints one_of: [:sms_number_missing, :sms_number_format, :sms_country_not_supported, :sms_credit, :sms_server, :sms_acc, :sms_blacklist, :sms_duplicate, :sms_optout, :sms_registration_needed, :sms_invalid_destination, :sms_not_allowed, :sms_rejected, :unknown]
      public? true
      description "失败分类"
    end
    attribute :to_delete, :boolean do
      default false
      public? true
      description "软删除标记，供 GC 清理"
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
      change set_attribute(:id, expr(id))
    end
    update :send do
      description "发送短信（outgoing → process → pending/sent/error）"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :process)
      change UniboV4.Marketing.Changes.SmsMessage.SendCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消发送（outgoing → canceled）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :resend_failed do
      description "重试失败短信（error → outgoing）"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :outgoing)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
