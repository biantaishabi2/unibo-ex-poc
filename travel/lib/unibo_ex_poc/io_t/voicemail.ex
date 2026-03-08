# Workflow: voicemail_lifecycle — 语音信箱留言创建、阅读、归档与转写流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   mark_read --> [*]
#   transcribe --> [*]
#   archive --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.Voicemail do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.IoT.Voicemail.Notifier]

  resource do
    description "语音留言存储和管理，基于 OFBiz CommunicationEvent 扩展"
  end

  postgres do
    table "io_t_voicemails"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_voicemail

    queries do
      get :get_io_t_voicemail, :read
      list :list_io_t_voicemails, :read
    end

    mutations do
      create :create_io_t_voicemail, :create
      update :mark_read_io_t_voicemail, :mark_read
      update :archive_io_t_voicemail, :archive
      update :transcribe_io_t_voicemail, :transcribe
      destroy :delete_io_t_voicemail, :destroy
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
      description "来电号码"
    end
    attribute :duration, :integer do
      public? true
      description "留言时长（秒）"
    end
    attribute :recording_url, :string do
      public? true
      description "录音 URL"
    end
    attribute :transcription, :string do
      public? true
      description "语音转文字"
    end
    attribute :transcription_status, :atom do
      constraints one_of: [:pending, :processing, :completed, :failed]
      public? true
      description "转写状态"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:unread, :read, :archived]
      default :unread
      public? true
      description "留言状态"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user, UniboExPoc.IoT.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :call, UniboExPoc.IoT.VoIPCall do
      public? true
      attribute_type :integer
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :incoming_numbers, UniboExPoc.IoT.IncomingNumber do
      public? true
      destination_attribute :voicemail_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:caller, :duration, :recording_url, :org_id]
      argument :user_id, :integer, allow_nil?: false
      argument :call_id, :integer
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:caller)
      validate present(:org_id)
      validate present([:user_id])
      change set_attribute(:id, expr(id))
    end
    update :mark_read do
      description "标记已读"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :unread do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :unread}))
        end
      end
      # message: "只有未读留言可以标记已读"
      change set_attribute(:state, :read)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档语音留言"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:unread, :read] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:unread, :read]}))
        end
      end
      # message: "只有未读或已读留言可以归档"
      change set_attribute(:state, :archived)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :transcribe do
      description "更新转写内容"
      accept [:transcription, :transcription_status]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:incoming_numbers]
  end

end
