defmodule HospitalScheduling.Scheduling.ScheduleVersion do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "一个周期内的工作版本或已发布版本"
  end

  postgres do
    table "scheduling_schedule_versions"
    repo HospitalScheduling.Repo
    identity_index_names unique_period_version_no: "idx_scheduling_schedule_versions_unique_period_version_no"
  end

  graphql do
    type :scheduling_schedule_version

    queries do
      get :get_scheduling_schedule_version, :read
      list :list_scheduling_schedule_versions, :read
    end

    mutations do
      create :create_scheduling_schedule_version, :create
      update :update_scheduling_schedule_version, :update
      update :publish_version_scheduling_schedule_version, :publish_version
      update :archive_version_scheduling_schedule_version, :archive_version
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :version_no, :integer do
      allow_nil? false
      public? true
      description "版本号"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:working, :published, :archived]
      default :working
      public? true
      description "版本状态"
    end
    attribute :origin_type, :atom do
      allow_nil? false
      constraints one_of: [:manual, :solver, :cloned_from_previous]
      default :manual
      public? true
      description "版本来源类型"
    end
    attribute :created_by, :uuid do
      public? true
      description "操作者"
    end
    attribute :change_summary, :string do
      public? true
      description "版本说明"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
      allow_nil? false
    end
    belongs_to :based_on_run, HospitalScheduling.Scheduling.SolverRun do
      public? true
    end
    belongs_to :source_version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
    end
    has_many :shift_assignments, HospitalScheduling.Scheduling.ShiftAssignment do
      public? true
      destination_attribute :version_id
    end
    has_many :constraint_violations, HospitalScheduling.Scheduling.ConstraintViolation do
      public? true
      destination_attribute :version_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Schedule Version via Create. doc_url: graphql://contract/scheduling/create_scheduling_schedule_version"
      primary? true
      accept [:period_id, :version_no, :origin_type, :created_by, :based_on_run_id, :source_version_id, :change_summary]
      argument :period_id, :uuid, allow_nil?: false
      change manage_relationship(:period_id, :period, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Schedule Version via Update. doc_url: graphql://contract/scheduling/update_scheduling_schedule_version"
      primary? true
      accept [:change_summary]
      require_atomic? false
    end
    update :publish_version do
      description "发布此版本

发布此版本. doc_url: graphql://contract/scheduling/publish_version_scheduling_schedule_version"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :working do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :working}))
        end
      end
      # message: "只有工作中的版本可以发布"
      change HospitalScheduling.Scheduling.Changes.ScheduleVersion.PublishVersionCall1
      change set_attribute(:status, :published)
      require_atomic? false
    end
    update :archive_version do
      description "归档此版本

归档此版本. doc_url: graphql://contract/scheduling/archive_version_scheduling_schedule_version"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:working, :published] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:working, :published]}))
        end
      end
      # message: "只有工作中或已发布的版本可以归档"
      change set_attribute(:status, :archived)
      require_atomic? false
    end
  end

  identities do
    identity :unique_period_version_no, [:period_id, :version_no]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, HospitalScheduling.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end


  pub_sub do
    module HospitalScheduling.PubSub
    prefix "schedule_version"

    publish :publish_version, ["scheduling.version.published"]
    publish :archive_version, ["scheduling.version.archived"]
  end
end
