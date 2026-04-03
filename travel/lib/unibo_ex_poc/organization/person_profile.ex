defmodule UniboExPoc.Organization.PersonProfile do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "人员主档，复用 Party 作为统一主体，不单独复制第二套 person 实体"
  end

  postgres do
    table "organization_person_profiles"
    repo UniboExPoc.Repo
    identity_index_names unique_person_party: "idx_organization_person_profiles_unique_person_party"
  end

  graphql do
    type :organization_person_profile

    queries do
      get :get_organization_person_profile, :read
      list :list_organization_person_profiles, :read
    end

    mutations do
      create :create_organization_person_profile, :create
      update :update_organization_person_profile, :update
      update :reassign_org_organization_person_profile, :reassign_org
      update :suspend_organization_person_profile, :suspend
      update :resume_organization_person_profile, :resume
      update :archive_organization_person_profile, :archive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :full_name, :string do
      allow_nil? false
      public? true
      description "人员展示姓名"
    end
    attribute :mobile, :string do
      public? true
      description "手机号，作为主要去重线索之一"
    end
    attribute :employee_code, :string do
      public? true
      description "工号，作为企业内稳定标识"
    end
    attribute :national_id, :string do
      public? true
      description "身份证号，作为高优先级去重线索"
    end
    attribute :gender, :atom do
      constraints one_of: [:male, :female, :unknown]
      default :unknown
      public? true
      description "性别"
    end
    attribute :join_channel, :atom do
      constraints one_of: [:self_signup, :operator_created, :imported, :synced]
      default :operator_created
      public? true
      description "入会/建档来源"
    end
    attribute :member_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :active, :suspended, :archived]
      default :pending
      public? true
      description "会员/人员状态"
    end
    attribute :archived_reason, :string do
      public? true
      description "归档原因"
    end
    attribute :archived_at, :utc_datetime do
      public? true
      description "归档时间"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :person_party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
    belongs_to :current_org_party, UniboExPoc.Organization.Party do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Person Profile via Create. doc_url: graphql://contract/organization/create_organization_person_profile"
      primary? true
      accept [:full_name, :mobile, :employee_code, :national_id, :gender, :join_channel, :person_party_id, :current_org_party_id]
      argument :person_party_id, :uuid, allow_nil?: false
      change manage_relationship(:person_party_id, :person_party, type: :append, on_lookup: :relate)
      validate present(:full_name)
    end
    update :update do
      description "Update Person Profile via Update. doc_url: graphql://contract/organization/update_organization_person_profile"
      primary? true
      accept [:full_name, :mobile, :employee_code, :national_id, :gender]
      require_atomic? false
    end
    update :reassign_org do
      description "调整当前组织归属，不创建第二个人员实体

调整当前组织归属，不创建第二个人员实体. doc_url: graphql://contract/organization/reassign_org_organization_person_profile"
      accept []
      argument :current_org_party_id, :uuid
      require_atomic? false
    end
    update :suspend do
      description "暂停人员/会员资格

暂停人员/会员资格. doc_url: graphql://contract/organization/suspend_organization_person_profile"
      accept []
      change set_attribute(:member_status, :suspended)
      change AshStateMachine.BuiltinChanges.transition_state(:suspended)
      require_atomic? false
    end
    update :resume do
      description "恢复人员/会员资格

恢复人员/会员资格. doc_url: graphql://contract/organization/resume_organization_person_profile"
      accept []
      change set_attribute(:member_status, :active)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :archive do
      description "归档人员并从后续授权对象集合中移除

归档人员并从后续授权对象集合中移除. doc_url: graphql://contract/organization/archive_organization_person_profile"
      accept [:archived_reason]
      change set_attribute(:member_status, :archived)
      change set_attribute(:archived_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:archived)
      require_atomic? false
    end
  end

  identities do
    identity :unique_person_party, [:person_party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :active, :suspended, :archived]
    state_attribute :member_status
    transitions do
      transition :create, from: :pending, to: :active
      transition :suspend, from: :active, to: :suspended
      transition :resume, from: :suspended, to: :active
      transition :archive, from: :pending, to: :archived
      transition :archive, from: :active, to: :archived
      transition :archive, from: :suspended, to: :archived
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "person_profile"

    publish :archive, ["people.person_profile.archived"]
  end
end
