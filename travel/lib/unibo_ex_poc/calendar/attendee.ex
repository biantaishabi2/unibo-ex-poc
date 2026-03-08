# Workflow: attendee_response_flow — 参与者邀请与响应流程
# ```mermaid
# stateDiagram-v2
#   [*] --> invite
#   invite --> update_response
#   invite --> remove
#   update_response --> update_response
#   update_response --> remove
#   remove --> [*]
# ```
defmodule UniboExPoc.Calendar.Attendee do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "日历事件参与者，记录邀请和响应状态"
  end

  postgres do
    table "calendar_attendees"
    repo UniboExPoc.Repo
  end

  graphql do
    type :calendar_attendee

    queries do
      get :get_calendar_attendee, :read
      list :list_calendar_attendees, :read
    end

    mutations do
      create :create_invite_calendar_attendee, :invite
      update :update_response_calendar_attendee, :update_response
      destroy :delete_remove_calendar_attendee, :remove
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :response_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :accepted, :declined, :tentative]
      default :pending
      public? true
      description "响应状态（对齐 WorkEffortPartyAssignment.status_id / availability_status_id）"
    end
    attribute :is_organizer, :boolean do
      default false
      public? true
      description "是否为组织者（对齐 WorkEffortPartyAssignment.role_type_id 判断）"
    end
    attribute :role, :atom do
      constraints one_of: [:organizer, :required, :optional, :resource]
      default :required
      public? true
      description "参与角色（对齐 WorkEffortPartyAssignment.role_type_id）"
    end
    attribute :must_rsvp, :boolean do
      default false
      public? true
      description "是否强制回复（对齐 WorkEffortPartyAssignment.must_rsvp）"
    end
    attribute :comments, :string do
      public? true
      description "备注（对齐 WorkEffortPartyAssignment.comments）"
    end
    attribute :responded_at, :utc_datetime do
      public? true
      description "响应时间（对齐 WorkEffortPartyAssignment.status_date_time）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Calendar.Party do
      public? true
    end
    belongs_to :event, UniboExPoc.Calendar.CalendarEvent do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :invite do
      description "邀请参与者"
      primary? true
      accept [:event_id, :party_id, :role, :is_organizer, :must_rsvp, :comments]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:party_id)
      change set_attribute(:id, expr(id))
    end
    update :update_response do
      description "更新响应状态"
      primary? true
      accept [:response_status, :comments]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :remove do
      description "移除参与者"
      primary? true
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_event_party, [:event_id, :party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
