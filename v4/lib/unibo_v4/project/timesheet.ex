defmodule UniboV4.Project.Timesheet do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Project.Timesheet.Notifier]

  postgres do
    table "timesheets"
    repo UniboV4.Repo
  end

  graphql do
    type :timesheet

    queries do
      get :get_timesheet, :read
      list :list_timesheets, :read
    end

    mutations do
      create :create_timesheet, :create
      update :submit_timesheet, :submit
      update :approve_timesheet, :approve
      update :reject_timesheet, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :period, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected]
      default :draft
    end
    attribute :total_hours, :decimal
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :entries, UniboV4.Project.TimesheetEntry
    belongs_to :employee, UniboV4.Accounts.User do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:period, :notes]
      argument :entries, {:array, :string}
      change manage_relationship(:entries, :entries, type: :create)
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change relate_actor(:employee)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :entries, {:array, :map}, default: []
      change manage_relationship(:entries, :entries, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      argument :entries, {:array, :map}, default: []
      change manage_relationship(:entries, :entries, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :reject do
      accept []
      argument :entries, {:array, :map}, default: []
      change manage_relationship(:entries, :entries, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      change set_attribute(:status, :rejected)
    end
  end

end
