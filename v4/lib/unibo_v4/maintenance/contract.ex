# Workflow: contract_lifecycle — 车辆合同生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> action_open
#   action_open --> action_expire
#   action_expire --> action_close
#   action_expire --> action_draft
#   action_close --> [*]
#   action_draft --> action_open
# ```
defmodule UniboV4.Maintenance.Contract do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_contracts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:futur, :open, :expired, :closed]
      default :futur
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :start_date, :date do
      default &Date.utc_today/0
      public? true
    end
    attribute :expiration_date, :date, public?: true
    attribute :cost_generated, :decimal, public?: true
    attribute :cost_frequency, :atom do
      constraints one_of: [:no, :daily, :weekly, :monthly, :yearly]
      default :monthly
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :days_left, :integer, public?: true
    attribute :expires_today, :boolean, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :cost_subtype, UniboV4.Maintenance.ServiceType do
      public? true
    end
    belongs_to :insurer, UniboV4.Maintenance.Partner do
      public? true
    end
    belongs_to :responsible, UniboV4.Maintenance.User do
      public? true
    end
    many_to_many :service_items, UniboV4.Maintenance.ServiceType do
      public? true
      through UniboV4.Maintenance.ContractServiceItemLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:amount, :start_date, :expiration_date, :cost_generated, :cost_frequency]
      argument :vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :action_open do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :futur do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :futur}))
        end
      end
      # message: "只有即将生效状态可以开放"
      change set_attribute(:state, :open)
      # TODO: 不支持的 change effect auto_state_transition
      # TODO: 不支持的 change effect reschedule_renewal_activity
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
    update :action_expire do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :open do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :open}))
        end
      end
      # message: "只有生效中状态可以过期"
      change set_attribute(:state, :expired)
      # TODO: 不支持的 change effect auto_state_transition
      # TODO: 不支持的 change effect reschedule_renewal_activity
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
    update :action_close do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :expired do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :expired}))
        end
      end
      # message: "只有已过期状态可以关闭"
      change set_attribute(:state, :closed)
      # TODO: 不支持的 change effect auto_state_transition
      # TODO: 不支持的 change effect reschedule_renewal_activity
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
    update :action_draft do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :expired do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :expired}))
        end
      end
      # message: "只有已过期状态可以重置"
      change set_attribute(:state, :futur)
      # TODO: 不支持的 change effect auto_state_transition
      # TODO: 不支持的 change effect reschedule_renewal_activity
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

end
