# Workflow: assignment_management — 技术员分配管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Helpdesk.FieldServiceAssignment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "现场技术员分配"
  end

  postgres do
    table "helpdesk_field_service_assignments"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_field_service_assignment

    queries do
      get :get_helpdesk_field_service_assignment, :read
      list :list_helpdesk_field_service_assignments, :read
    end

    mutations do
      create :create_helpdesk_field_service_assignment, :create
      destroy :delete_helpdesk_field_service_assignment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      default "technician"
      public? true
    end
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :service_order, UniboV4.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
    end
    belongs_to :technician, UniboV4.Helpdesk.Party do
      public? true
      allow_nil? false
      source_attribute :technician_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:role, :from_date, :thru_date]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :technician_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:technician_id, :technician, type: :append, on_lookup: :relate)
      validate present(:from_date)
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
