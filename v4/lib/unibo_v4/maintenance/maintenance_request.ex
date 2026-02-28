defmodule UniboV4.Maintenance.MaintenanceRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Maintenance.MaintenanceRequest.Notifier]

  postgres do
    table "maintenance_requests"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_request

    queries do
      get :get_maintenance_request, :read
      list :list_maintenance_requests, :read
    end

    mutations do
      create :create_maintenance_request, :create
      update :start_maintenance_request, :start
      update :complete_maintenance_request, :complete
      update :cancel_maintenance_request, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :request_number, :string, allow_nil?: false
    attribute :maintenance_type, :atom do
      allow_nil? false
      constraints one_of: [:corrective, :preventive]
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
    end
    attribute :status, :atom do
      constraints one_of: [:requested, :in_progress, :completed, :cancelled]
      default :requested
    end
    attribute :description, :string, allow_nil?: false
    attribute :requested_date, :date, allow_nil?: false
    attribute :scheduled_date, :date
    attribute :completed_date, :date
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      allow_nil? false
    end
    belongs_to :requested_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:request_number, :maintenance_type, :priority, :description, :requested_date, :scheduled_date, :notes]
      argument :equipment_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      validate present(:request_number)
      change relate_actor(:requested_by)
    end
    update :start do
      accept []
      validate attribute_equals(:status, :requested) do
        message "只有已请求状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
    update :cancel do
      accept []
      validate attribute_equals(:status, :requested) do
        message "只有已请求状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_request_number, [:request_number]
  end

end
