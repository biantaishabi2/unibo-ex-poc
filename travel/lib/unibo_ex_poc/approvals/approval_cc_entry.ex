defmodule UniboExPoc.Approvals.ApprovalCcEntry do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine]

  resource do
    description "审批抄送记录，表达某一步抄送给谁以及其查看状态"
  end

  postgres do
    table "approvals_approval_cc_entries"
    repo UniboExPoc.Repo
    identity_index_names unique_cc_per_step: "idx_approvals_approval_cc_entries_unique_cc_per_step"
  end

  graphql do
    type :approvals_approval_cc_entry

    queries do
      get :get_approvals_approval_cc_entry, :read
      list :list_approvals_approval_cc_entrys, :read
    end

    mutations do
      create :create_create_cc_entry_approvals_approval_cc_entry, :create_cc_entry
      update :mark_seen_approvals_approval_cc_entry, :mark_seen
      update :ignore_cc_entry_approvals_approval_cc_entry, :ignore_cc_entry
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :cc_title, :string do
      allow_nil? false
      public? true
      description "抄送标题快照"
    end
    attribute :step_index, :integer do
      allow_nil? false
      public? true
      description "抄送对应的审批步骤号"
    end
    attribute :cc_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :seen, :ignored]
      default :pending
      public? true
      description "抄送查看状态"
    end
    attribute :routing_snapshot, :map do
      public? true
      description "当前抄送解析快照，记录抄送来源与组织关系依据"
    end
    attribute :delivered_at, :utc_datetime do
      public? true
      description "抄送送达时间"
    end
    attribute :seen_at, :utc_datetime do
      public? true
      description "抄送查看时间"
    end
    attribute :ignored_at, :utc_datetime do
      public? true
      description "抄送忽略时间"
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
    belongs_to :instance, UniboExPoc.Approvals.ApprovalInstance do
      public? true
      allow_nil? false
    end
    belongs_to :recipient_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create_cc_entry do
      description "Create Approval Cc Entry via Create Cc Entry. doc_url: graphql://contract/approvals/create_create_cc_entry_approvals_approval_cc_entry"
      primary? true
      accept [:cc_title, :step_index, :routing_snapshot, :instance_id, :recipient_party_id]
      argument :instance_id, :uuid, allow_nil?: false
      change manage_relationship(:instance_id, :instance, type: :append, on_lookup: :relate)
      argument :recipient_party_id, :uuid, allow_nil?: false
      change manage_relationship(:recipient_party_id, :recipient_party, type: :append, on_lookup: :relate)
      validate compare(:step_index, greater_than_or_equal_to: 1)
      # message: "抄送步骤号至少为 1"
      change set_attribute(:cc_status, :pending)
      change set_attribute(:delivered_at, &DateTime.utc_now/0)
    end
    update :mark_seen do
      description "Update Approval Cc Entry via Mark Seen. doc_url: graphql://contract/approvals/mark_seen_approvals_approval_cc_entry"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :cc_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :cc_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待查看抄送可以流转"
      change set_attribute(:cc_status, :seen)
      change set_attribute(:seen_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:seen)
      require_atomic? false
    end
    update :ignore_cc_entry do
      description "Update Approval Cc Entry via Ignore Cc Entry. doc_url: graphql://contract/approvals/ignore_cc_entry_approvals_approval_cc_entry"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :cc_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :cc_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待查看抄送可以流转"
      change set_attribute(:cc_status, :ignored)
      change set_attribute(:ignored_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:ignored)
      require_atomic? false
    end
  end

  identities do
    identity :unique_cc_per_step, [:instance_id, :step_index, :recipient_party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :seen, :ignored]
    state_attribute :cc_status
    transitions do
      transition :mark_seen, from: :pending, to: :seen
      transition :ignore_cc_entry, from: :pending, to: :ignored
    end
  end
end
