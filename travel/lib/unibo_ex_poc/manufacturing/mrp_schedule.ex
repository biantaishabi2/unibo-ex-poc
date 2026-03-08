# Workflow: mrp_schedule_create_flow — MRP 排程创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Manufacturing.MrpSchedule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "MRP 排程"
  end

  postgres do
    table "manufacturing_mrp_schedules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_mrp_schedule

    queries do
      get :get_manufacturing_mrp_schedule, :read
      list :list_manufacturing_mrp_schedules, :read
    end

    mutations do
      create :create_manufacturing_mrp_schedule, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string do
      allow_nil? false
      public? true
      description "产品编号"
    end
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:demand, :supply, :forecast]
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :event_date, :date do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:product_code, :event_type, :quantity, :event_date, :description]
      validate present(:product_code)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
  end

end
