defmodule UniboV4.HR.LeaveRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.HR.LeaveRequest.Notifier]

  postgres do
    table "leave_requests"
    repo UniboV4.Repo
  end

  graphql do
    type :leave_request

    queries do
      get :get_leave_request, :read
      list :list_leave_requests, :read
    end

    mutations do
      create :create_leave_request, :create
      update :submit_leave_request, :submit
      update :approve_leave_request, :approve
      update :reject_leave_request, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected, :cancelled]
      default :draft
        public? true
    end
    attribute :start_date, :date, allow_nil?: false, public?: true
    attribute :end_date, :date, allow_nil?: false, public?: true
    attribute :days, :decimal, allow_nil?: false, public?: true
    attribute :reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
        public? true
    end
    belongs_to :leave_type, UniboV4.HR.LeaveType do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:start_date, :end_date, :days, :reason]
      argument :employee_id, :uuid, allow_nil?: false
      argument :leave_type_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:leave_type_id, :leave_type, type: :append, on_lookup: :relate)
    end
    update :submit do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :reject do
      accept []
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      change set_attribute(:status, :rejected)
    end
  end

  validations do
    validate compare(:days, greater_than: 0)
  end

end
