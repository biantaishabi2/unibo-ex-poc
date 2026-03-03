# Workflow: voip_call_lifecycle_flow — 通话创建、接听、备注、结束与未接转语音流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   answer --> [*]
#   add_note --> [*]
#   end_call --> [*]
#   miss --> [*]
#   to_voicemail --> [*]
# ```
defmodule UniboV4.IoT.VoIPCall do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.IoT.VoIPCall.Notifier]

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
      update :answer_io_t_vo_ip_call, :answer
      update :end_call_io_t_vo_ip_call, :end_call
      update :miss_io_t_vo_ip_call, :miss
      update :to_voicemail_io_t_vo_ip_call, :to_voicemail
      update :add_note_io_t_vo_ip_call, :add_note
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :caller, :string do
      allow_nil? false
      public? true
    end
    attribute :callee, :string do
      allow_nil? false
      public? true
    end
    attribute :direction, :atom do
      allow_nil? false
      constraints one_of: [:inbound, :outbound]
      public? true
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:ringing, :in_progress, :completed, :missed, :voicemail]
      default :ringing
      public? true
    end
    attribute :disposition, :atom do
      constraints one_of: [:answered, :no_answer, :busy, :failed, :voicemail, :cancelled]
      public? true
    end
    attribute :user_id, :integer, public?: true
    attribute :org_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :provider_id, :integer, public?: true
    attribute :start_time, :utc_datetime, public?: true
    attribute :end_time, :utc_datetime, public?: true
    attribute :recording_url, :string, public?: true
    attribute :recording_duration, :integer, public?: true
    attribute :transcription, :string, public?: true
    attribute :transcription_status, :atom do
      constraints one_of: [:pending, :processing, :completed, :failed]
      public? true
    end
    attribute :notes, :string, public?: true
    attribute :tags, :string, public?: true
    attribute :sip_call_id, :string, public?: true
    attribute :linked_contact_id, :integer, public?: true
    attribute :linked_lead_id, :integer, public?: true
    attribute :linked_ticket_id, :integer, public?: true
    attribute :linked_model, :string, public?: true
    attribute :linked_record_id, :integer, public?: true
    attribute :queue_id, :integer, public?: true
    attribute :transfer_from_call_id, :integer, public?: true
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :duration
    # TODO: 不支持的 calculation 表达式 :wait_time
    # TODO: 不支持的 calculation 表达式 :billsec
  end

  relationships do
    belongs_to :user, UniboV4.IoT.User do
      public? true
    end
    belongs_to :org, UniboV4.IoT.Org do
      public? true
      allow_nil? false
    end
    belongs_to :provider, UniboV4.IoT.VoIPProvider do
      public? true
    end
    belongs_to :linked_contact, UniboV4.IoT.Contact do
      public? true
    end
    belongs_to :linked_lead, UniboV4.IoT.CrmLead do
      public? true
    end
    belongs_to :linked_ticket, UniboV4.IoT.HelpdeskTicket do
      public? true
    end
    belongs_to :queue, UniboV4.IoT.CallQueue do
      public? true
    end
    belongs_to :transfer_from, UniboV4.IoT.VoIPCall do
      public? true
      source_attribute :transfer_from_call_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:caller, :callee, :direction, :user_id, :org_id, :queue_id, :sip_call_id]
      argument :org_id, :uuid, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:caller)
      validate present(:callee)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :answer do
      primary? true
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
      change set_attribute(:state, :in_progress)
      change set_attribute(:start_time, &DateTime.utc_now/0)
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
    update :end_call do
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
      change set_attribute(:state, :completed)
      change set_attribute(:end_time, &DateTime.utc_now/0)
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
    update :miss do
      accept []
      change set_attribute(:state, :missed)
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
    update :to_voicemail do
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
      change set_attribute(:state, :voicemail)
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
    update :add_note do
      accept [:notes, :tags]
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
