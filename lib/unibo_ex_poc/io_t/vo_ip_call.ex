# Workflow: voip_call_lifecycle_flow — 通话创建、接听、保持/恢复、转接、备注、结束与未接转语音流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   answer --> [*]
#   hold --> [*]
#   unhold --> [*]
#   transfer --> [*]
#   add_note --> [*]
#   end_call --> [*]
#   miss --> [*]
#   to_voicemail --> [*]
#   update --> [*]
# ```
defmodule UniboV4.IoT.VoIPCall do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.IoT.VoIPCall.Notifier]

  resource do
    description "通话记录，跟踪从振铃到结束的完整生命周期，支持保持/转接，自动关联联系人和商机"
  end

  postgres do
    table "io_t_vo_ip_calls"
    repo UniboV4.Repo
  end

  graphql do
    type :io_t_vo_ip_call

    queries do
      get :get_io_t_vo_ip_call, :read
      list :list_io_t_vo_ip_calls, :read
    end

    mutations do
      create :create_io_t_vo_ip_call, :create
      update :update_io_t_vo_ip_call, :update
      update :answer_io_t_vo_ip_call, :answer
      update :end_call_io_t_vo_ip_call, :end_call
      update :miss_io_t_vo_ip_call, :miss
      update :to_voicemail_io_t_vo_ip_call, :to_voicemail
      update :add_note_io_t_vo_ip_call, :add_note
      update :hold_io_t_vo_ip_call, :hold
      update :unhold_io_t_vo_ip_call, :unhold
      update :transfer_io_t_vo_ip_call, :transfer
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :caller, :string do
      allow_nil? false
      public? true
      description "主叫号码/分机"
    end
    attribute :callee, :string do
      allow_nil? false
      public? true
      description "被叫号码/分机"
    end
    attribute :direction, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound]
      public? true
      description "通话方向"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:ringing, :in_progress, :on_hold, :completed, :missed, :voicemail]
      default :ringing
      public? true
      description "通话状态（完整 enum）"
    end
    attribute :disposition, :atom do
      constraints one_of: [:answered, :no_answer, :busy, :failed, :voicemail, :cancelled]
      public? true
      description "结束原因"
    end
    attribute :start_time, :utc_datetime do
      public? true
      description "接通时间"
    end
    attribute :end_time, :utc_datetime do
      public? true
      description "挂断时间"
    end
    attribute :duration, :integer do
      default 0
      public? true
      description "通话时长（秒）"
    end
    attribute :recording_url, :string do
      public? true
      description "录音文件 URL"
    end
    attribute :recording_duration, :integer do
      public? true
      description "录音时长（秒）"
    end
    attribute :transcription, :string do
      public? true
      description "通话转写文本"
    end
    attribute :transcription_status, :atom do
      constraints one_of: [:pending, :processing, :completed, :failed]
      public? true
      description "转写状态"
    end
    attribute :notes, :string do
      public? true
      description "通话备注"
    end
    attribute :tags, :string do
      public? true
      description "标签"
    end
    attribute :sip_call_id, :string do
      public? true
      description "SIP Call-ID header"
    end
    attribute :linked_model, :string do
      public? true
      description "通用关联模型名"
    end
    attribute :linked_record_id, :integer do
      public? true
      description "通用关联记录 ID"
    end
    attribute :transfer_to, :string do
      public? true
      description "转接目标号码/分机"
    end
    attribute :transfer_type, :atom do
      constraints one_of: [:blind, :attended]
      public? true
      description "转接类型（盲转/咨询转）"
    end
    attribute :hold_duration, :integer do
      default 0
      public? true
      description "累计保持时长（秒）"
    end
    attribute :hold_started_at, :utc_datetime do
      public? true
      description "保持开始时间（用于计算累计时长）"
    end
  end

  calculations do
    calculate :wait_time, :integer, expr(datetime_diff_seconds(start_time, created_at))
    calculate :billsec, :integer, {UniboV4.IoT.Calculations.VoIpCall.Billsec, []}
  end

  relationships do
    belongs_to :user, UniboV4.IoT.Party do
      public? true
      source_attribute :user_party_id
    end
    belongs_to :org, UniboV4.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :provider, UniboV4.IoT.VoIPProvider do
      public? true
      attribute_type :integer
    end
    belongs_to :linked_contact, UniboV4.IoT.Contact do
      public? true
      attribute_type :integer
    end
    belongs_to :linked_lead, UniboV4.IoT.CrmLead do
      public? true
      attribute_type :integer
    end
    belongs_to :linked_ticket, UniboV4.IoT.HelpdeskTicket do
      public? true
      attribute_type :integer
    end
    belongs_to :queue, UniboV4.IoT.CallQueue do
      public? true
      attribute_type :integer
    end
    belongs_to :transfer_from, UniboV4.IoT.VoIPCall do
      public? true
      source_attribute :transfer_from_call_id
      attribute_type :integer
    end
    has_one :voicemail, UniboV4.IoT.Voicemail do
      public? true
      source_attribute :transfer_from_call_id
      destination_attribute :call_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:caller, :callee, :direction, :org_id, :queue_id, :sip_call_id]
      argument :user_id, :uuid
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:caller)
      validate present(:callee)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:notes, :tags, :linked_contact_id, :linked_lead_id, :linked_ticket_id, :linked_model, :linked_record_id]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :answer do
      description "接听通话"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :ringing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :ringing}))
        end
      end
      # message: "只有振铃中的通话可以接听"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :in_progress)
      change set_attribute(:start_time, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :end_call do
      description "结束通话"
      argument :hangup_cause, :string
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:ringing, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:ringing, :in_progress]}))
        end
      end
      # message: "只有振铃或通话中的通话可以结束"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :completed)
      change set_attribute(:end_time, &DateTime.utc_now/0)
      change UniboV4.IoT.Changes.VoIpCall.ComputeDuration
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :miss do
      description "标记未接"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :missed)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :to_voicemail do
      description "转语音信箱"
      accept [:recording_url, :recording_duration]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :missed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :missed}))
        end
      end
      # message: "只有未接通话可以转语音信箱"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :voicemail)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :add_note do
      description "添加备注"
      accept [:notes, :tags]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :hold do
      description "通话保持"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有通话中的通话可以保持"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :on_hold)
      change set_attribute(:hold_started_at, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unhold do
      description "恢复通话"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :on_hold do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :on_hold}))
        end
      end
      # message: "只有保持中的通话可以恢复"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :in_progress)
      change UniboV4.IoT.Changes.VoIpCall.ComputeHoldDuration
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :transfer do
      description "转接通话"
      argument :target_number, :string, allow_nil?: false
      argument :transfer_mode, :string, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:in_progress, :on_hold] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:in_progress, :on_hold]}))
        end
      end
      # message: "只有通话中或保持中的通话可以转接"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:transfer_to, expr(^arg(:target_number)))
      change set_attribute(:transfer_type, expr(^arg(:transfer_mode)))
      change set_attribute(:state, :completed)
      change set_attribute(:end_time, &DateTime.utc_now/0)
      change UniboV4.IoT.Changes.VoIpCall.ComputeDuration
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
