defmodule UniboV4.Helpdesk.FieldServiceAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "field_service_assignments"
    repo UniboV4.Repo
  end

  graphql do
    type :field_service_assignment

    queries do
      get :get_field_service_assignment, :read
      list :list_field_service_assignments, :read
    end

    mutations do
      create :create_field_service_assignment, :create
      destroy :delete_field_service_assignment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string, default: "technician", public?: true
    attribute :from_date, :date, allow_nil?: false, public?: true
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :service_order, UniboV4.Helpdesk.FieldServiceOrder do
      allow_nil? false
        public? true
    end
    belongs_to :technician, UniboV4.Accounts.User do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role, :from_date, :thru_date]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :technician_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:technician_id, :technician, type: :append, on_lookup: :relate)
    end
  end

end
