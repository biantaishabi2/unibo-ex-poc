defmodule UniboExPoc.Ofbiz.Party.CommunicationEvent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_communication_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_communication_event

    queries do
      get :get_party_communication_event, :read
      list :list_party_communication_events, :read
    end

    mutations do
      create :create_party_communication_event, :create
      update :update_party_communication_event, :update
      destroy :delete_party_communication_event, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :communication_event_id, :string do
      public? true
      description "沟通活动编号"
    end
    attribute :orig_comm_event_id, :string do
      public? true
      description "原始沟通活动编号"
    end
    attribute :parent_comm_event_id, :string do
      public? true
      description "父级沟通活动编号"
    end
    attribute :entry_date, :utc_datetime do
      public? true
      description "凭证日期"
    end
    attribute :datetime_started, :utc_datetime do
      public? true
      description "开始时间"
    end
    attribute :datetime_ended, :utc_datetime do
      public? true
      description "结束时间"
    end
    attribute :subject, :string do
      public? true
      description "主题"
    end
    attribute :content, :string do
      public? true
      description "内容"
    end
    attribute :note, :string do
      public? true
      description "备注"
    end
    attribute :header_string, :string do
      public? true
      description "表头文本"
    end
    attribute :from_string, :string do
      public? true
      description "来源文本"
    end
    attribute :to_string, :string do
      public? true
      description "收件人"
    end
    attribute :cc_string, :string do
      public? true
      description "抄送"
    end
    attribute :bcc_string, :string do
      public? true
      description "密送"
    end
    attribute :message_id, :string do
      public? true
      description "消息编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :communication_event_type, UniboExPoc.Ofbiz.Party.CommunicationEventType do
      public? true
    end
    belongs_to :to_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :to_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_to
    end
    belongs_to :from_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :from_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_from
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Party.StatusItem do
      public? true
      source_attribute :status_id
    end
    belongs_to :contact_mech_type, UniboExPoc.Ofbiz.Party.ContactMechType do
      public? true
    end
    belongs_to :from_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_from
    end
    belongs_to :to_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_to
    end
    belongs_to :contact_list, UniboExPoc.Ofbiz.Party.ContactList do
      public? true
    end
    belongs_to :mime_type, UniboExPoc.Ofbiz.Party.MimeType do
      public? true
      source_attribute :content_mime_type_id
    end
    belongs_to :enumeration, UniboExPoc.Ofbiz.Party.Enumeration do
      public? true
      source_attribute :reason_enum_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
