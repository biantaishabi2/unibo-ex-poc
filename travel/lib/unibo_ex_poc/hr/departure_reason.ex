# Workflow: departure_reason_write_flow — DepartureReason 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.DepartureReason do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "离职原因"
  end

  postgres do
    table "hr_departure_reasons"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_departure_reason

    queries do
      get :get_hr_departure_reason, :read
      list :list_hr_departure_reasons, :read
    end

    mutations do
      create :create_hr_departure_reason, :create
      update :update_hr_departure_reason, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :reason_code, :string, public?: true
    attribute :sequence, :integer do
      default 0
      public? true
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
    has_many :employees, UniboExPoc.HR.Employee do
      public? true
      destination_attribute :departure_reason_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Departure Reason via Create. doc_url: graphql://contract/hr/create_hr_departure_reason"
      primary? true
      accept [:name, :reason_code, :sequence]
      validate present(:name)
    end
    update :update do
      description "Update Departure Reason via Update. doc_url: graphql://contract/hr/update_hr_departure_reason"
      primary? true
      accept [:name, :reason_code, :sequence]
      require_atomic? false
    end
  end

end
