# Workflow: alert_lifecycle — 质量警报全生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   confirm --> start_progress
#   start_progress --> done
#   start_progress --> create_maintenance_request
#   done --> [*] : done
# ```
defmodule UniboExPoc.Quality.QualityAlert do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Quality.QualityAlert.Notifier]

  resource do
    description "质量警报，支持 CAPA 闭环、根因分析和维保联动，状态机 draft→confirmed→in_progress→done"
  end

  postgres do
    table "quality_alerts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_alert

    queries do
      get :get_quality_quality_alert, :read
      list :list_quality_quality_alerts, :read
    end

    mutations do
      create :create_quality_quality_alert, :create
      update :update_quality_quality_alert, :update
      update :confirm_quality_quality_alert, :confirm
      update :start_progress_quality_quality_alert, :start_progress
      update :done_quality_quality_alert, :done
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "警报编号（自动生成）"
    end
    attribute :title, :string do
      allow_nil? false
      public? true
      description "警报标题"
    end
    attribute :stage, :atom do
      allow_nil? false
      constraints one_of: [:draft, :confirmed, :in_progress, :done]
      default :draft
      public? true
      description "警报阶段"
    end
    attribute :priority, :atom do
      allow_nil? false
      constraints one_of: [:low, :medium, :high, :critical]
      default :medium
      public? true
      description "优先级"
    end
    attribute :rca_method, :atom do
      constraints one_of: [:five_why, :fishbone, :"8d"]
      public? true
      description "根因分析方法"
    end
    attribute :description, :string do
      public? true
      description "问题描述"
    end
    attribute :corrective_action, :string do
      public? true
      description "纠正措施"
    end
    attribute :preventive_action, :string do
      public? true
      description "预防措施"
    end
    attribute :date_assign, :utc_datetime do
      public? true
      description "分配日期"
    end
    attribute :date_close, :utc_datetime do
      public? true
      description "关闭日期"
    end
    attribute :verification_date, :utc_datetime do
      public? true
      description "效果验证日期"
    end
    attribute :verification_result, :string do
      public? true
      description "验证结果"
    end
    attribute :ref_type, :string do
      public? true
      description "多态关联类型：production / picking"
    end
    attribute :ref_id, :integer do
      public? true
      description "关联单据 ID"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :product, UniboExPoc.Quality.Product do
      public? true
    end
    belongs_to :lot, UniboExPoc.Quality.Lot do
      public? true
    end
    belongs_to :check, UniboExPoc.Quality.QualityCheck do
      public? true
    end
    belongs_to :team, UniboExPoc.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboExPoc.Quality.Party do
      public? true
      source_attribute :responsible_party_id
    end
    belongs_to :partner, UniboExPoc.Quality.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :root_cause, UniboExPoc.Quality.QualityReason do
      public? true
    end
    belongs_to :workcenter, UniboExPoc.Quality.Workcenter do
      public? true
    end
    belongs_to :maintenance_request, UniboExPoc.Quality.MaintenanceRequest do
      public? true
    end
    belongs_to :company, UniboExPoc.Quality.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :priority, :rca_method, :description, :ref_type, :ref_id]
      argument :company_id, :uuid, allow_nil?: false
      argument :product_id, :uuid
      argument :lot_id, :uuid
      argument :check_id, :uuid
      argument :team_id, :uuid
      argument :responsible_id, :uuid
      argument :partner_id, :uuid
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:title)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:title, :priority, :rca_method, :description, :corrective_action, :preventive_action, :verification_date, :verification_result]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :confirm do
      description "确认警报"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :stage)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :stage, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:stage, :confirmed)
      change UniboExPoc.Quality.Changes.QualityAlert.ComputeDateAssign
      change UniboExPoc.Quality.Changes.QualityAlert.ConfirmCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start_progress do
      description "开始处理"
      accept []
      argument :responsible_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :stage)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :stage, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以开始处理"
      change set_attribute(:stage, :in_progress)
      change UniboExPoc.Quality.Changes.QualityAlert.StartProgressCall8
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :done do
      description "完成处理"
      accept [:corrective_action, :preventive_action]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :stage)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :stage, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有处理中状态可以完成"
      # skipped: validate present :corrective_action (incompatible with bulk update atomic path)
      # skipped: validate present :preventive_action (incompatible with bulk update atomic path)
      change set_attribute(:stage, :done)
      change UniboExPoc.Quality.Changes.QualityAlert.ComputeDateClose
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :create_maintenance_request do
      description "根因为设备问题时，一键创建 MaintenanceRequest 关联设备+工作中心"
      # precondition: requires stage=:in_progress
      validate attribute_equals(:stage, :in_progress)
      run fn input, _context ->
        # 根因为设备问题时创建维保请求，关联设备+工作中心 — 由 Change 模块处理: UniboExPoc.Quality.Changes.QualityAlert.CreateMaintenanceRequestComplex7
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(actor.role == :admin)
      authorize_if relates_to_actor_via(:company_party)
    end
    policy action_type(:create) do
      forbid_unless relates_to_actor_via(:company_party)
      authorize_if expr(actor.role in [:quality_inspector, :admin])
    end
    policy action_type(:update) do
      authorize_if expr(actor.role == :admin)
      authorize_if relates_to_actor_via(:company_party)
    end
    policy always() do
      authorize_if always()
    end
  end

end
