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
defmodule UniboV4.Quality.QualityAlert do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Quality.QualityAlert.Notifier]

  postgres do
    table "quality_alerts"
    repo UniboV4.Repo
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
    end
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :stage, :atom do
      allow_nil? false
      constraints one_of: [:draft, :confirmed, :in_progress, :done]
      default :draft
      public? true
    end
    attribute :priority, :atom do
      allow_nil? false
      constraints one_of: [:low, :medium, :high, :critical]
      default :medium
      public? true
    end
    attribute :rca_method, :atom do
      constraints one_of: [:five_why, :fishbone, :"8d"]
      public? true
    end
    attribute :description, :string, public?: true
    attribute :corrective_action, :string, public?: true
    attribute :preventive_action, :string, public?: true
    attribute :date_assign, :utc_datetime, public?: true
    attribute :date_close, :utc_datetime, public?: true
    attribute :verification_date, :utc_datetime, public?: true
    attribute :verification_result, :string, public?: true
    attribute :ref_type, :string, public?: true
    attribute :ref_id, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :product, UniboV4.Quality.Product do
      public? true
    end
    belongs_to :lot, UniboV4.Quality.Lot do
      public? true
    end
    belongs_to :check, UniboV4.Quality.QualityCheck do
      public? true
    end
    belongs_to :team, UniboV4.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboV4.Quality.User do
      public? true
    end
    belongs_to :partner, UniboV4.Quality.Partner do
      public? true
    end
    belongs_to :root_cause, UniboV4.Quality.QualityReason do
      public? true
    end
    belongs_to :workcenter, UniboV4.Quality.Workcenter do
      public? true
    end
    belongs_to :maintenance_request, UniboV4.Quality.MaintenanceRequest do
      public? true
    end
    belongs_to :company, UniboV4.Quality.Company do
      public? true
      allow_nil? false
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
      accept [:title, :priority, :rca_method, :description, :corrective_action, :preventive_action, :verification_date, :verification_result]
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
    update :confirm do
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
      # TODO: 跨实体聚合表达式暂不支持
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
    update :start_progress do
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
    update :done do
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
      # TODO: 跨实体聚合表达式暂不支持
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
    action :create_maintenance_request do
      validate attribute_equals(:stage, :in_progress)
      # message: "只有处理中阶段可以创建维保请求"
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
