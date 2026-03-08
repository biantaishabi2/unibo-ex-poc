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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "车辆合同，4 态状态机，支持定时任务自动状态迁移和续约提醒"
  end

  postgres do
    table "maintenance_contracts"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_contract

    queries do
      get :get_maintenance_contract, :read
      list :list_maintenance_contracts, :read
    end

    mutations do
      create :create_maintenance_contract, :create
      update :action_open_maintenance_contract, :action_open
      update :action_expire_maintenance_contract, :action_expire
      update :action_close_maintenance_contract, :action_close
      update :action_draft_maintenance_contract, :action_draft
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:futur, :open, :expired, :closed]
      default :futur
      public? true
      description "状态机: futur->open->expired->closed, expired->futur(重置)"
    end
    attribute :amount, :decimal do
      public? true
      description "一次性合同费用"
    end
    attribute :start_date, :date do
      default &Date.utc_today/0
      public? true
      description "开始日期"
    end
    attribute :expiration_date, :date do
      public? true
      description "到期日期（默认 today + 1 年）"
    end
    attribute :cost_generated, :decimal do
      public? true
      description "周期性费用金额"
    end
    attribute :cost_frequency, :atom do
      constraints one_of: [:no, :daily, :weekly, :monthly, :yearly]
      default :monthly
      public? true
      description "周期性费用频率"
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :days_left, :integer do
      public? true
      description "距到期天数，无日期时为 -1"
    end
    attribute :expires_today, :boolean do
      public? true
      description "今天是否到期"
    end
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
    belongs_to :insurer, UniboV4.Maintenance.Party do
      public? true
      source_attribute :insurer_party_id
    end
    belongs_to :responsible, UniboV4.Maintenance.Party do
      public? true
      source_attribute :responsible_party_id
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
      change set_attribute(:id, expr(id))
    end
    update :action_open do
      description "生效 (futur -> open)"
      primary? true
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
      change UniboV4.Maintenance.Changes.Contract.ActionOpenCall5
      change UniboV4.Maintenance.Changes.Contract.ActionOpenCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_expire do
      description "过期 (open -> expired)"
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
      change UniboV4.Maintenance.Changes.Contract.ActionExpireCall5
      change UniboV4.Maintenance.Changes.Contract.ActionExpireCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_close do
      description "关闭 (expired -> closed)"
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
      change UniboV4.Maintenance.Changes.Contract.ActionCloseCall5
      change UniboV4.Maintenance.Changes.Contract.ActionCloseCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_draft do
      description "重置为即将生效 (expired -> futur)"
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
      change UniboV4.Maintenance.Changes.Contract.ActionDraftCall5
      change UniboV4.Maintenance.Changes.Contract.ActionDraftCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
