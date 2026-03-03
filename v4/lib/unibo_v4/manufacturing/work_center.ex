# Workflow: work_center_status_flow — 工作中心创建、维护与阻塞状态切换流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   block --> [*]
#   unblock --> [*]
# ```
defmodule UniboV4.Manufacturing.WorkCenter do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_work_centers"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_work_center

    queries do
      get :get_manufacturing_work_center, :read
      list :list_manufacturing_work_centers, :read
    end

    mutations do
      create :create_manufacturing_work_center, :create
      update :update_manufacturing_work_center, :update
      update :block_manufacturing_work_center, :block
      update :unblock_manufacturing_work_center, :unblock
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :center_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :costs_hour, :decimal do
      default 0
      public? true
    end
    attribute :capacity, :decimal do
      default 1.0
      public? true
    end
    attribute :time_start, :decimal do
      default 0
      public? true
    end
    attribute :time_stop, :decimal do
      default 0
      public? true
    end
    attribute :time_efficiency, :decimal do
      default 100
      public? true
    end
    attribute :resource_calendar_id, :uuid, public?: true
    attribute :blocked, :boolean do
      default false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :maintenance]
      default :active
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :work_orders, UniboV4.Manufacturing.WorkOrder do
      public? true
    end
    has_many :productivity_records, UniboV4.Manufacturing.WorkcenterProductivity do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:center_code, :name, :costs_hour, :capacity, :time_start, :time_stop, :time_efficiency, :resource_calendar_id, :description]
      validate present(:center_code)
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :costs_hour, :capacity, :time_start, :time_stop, :time_efficiency, :resource_calendar_id, :status, :blocked, :description]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :block do
      accept []
      change set_attribute(:blocked, true)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :unblock do
      accept []
      change set_attribute(:blocked, false)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:capacity, greater_than: 0)
    validate compare(:time_efficiency, greater_than: 0)
  end

  identities do
    identity :unique_center_code, [:center_code]
  end

end
