# Workflow: quality_point_lifecycle — 质量控制点生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> deactivate
#   create --> trigger_checks
#   update --> deactivate
#   update --> trigger_checks
#   deactivate --> activate
#   activate --> update
#   activate --> deactivate
#   activate --> trigger_checks
#   trigger_checks --> [*]
# ```
defmodule UniboV4.Quality.QualityPoint do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_points"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_quality_point

    queries do
      get :get_quality_quality_point, :read
      list :list_quality_quality_points, :read
    end

    mutations do
      create :create_quality_quality_point, :create
      update :update_quality_quality_point, :update
      update :activate_quality_quality_point, :activate
      update :deactivate_quality_quality_point, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :operation_type, :atom do
      allow_nil? false
      constraints one_of: [:receipt, :manufacturing, :delivery, :internal_transfer]
      public? true
    end
    attribute :check_type, :atom do
      allow_nil? false
      constraints one_of: [:pass_fail, :measure, :picture, :instructions, :worksheet, :print_label]
      public? true
    end
    attribute :control_per, :atom do
      allow_nil? false
      constraints one_of: [:operation, :product, :quantity]
      default :operation
      public? true
    end
    attribute :control_frequency, :atom do
      allow_nil? false
      constraints one_of: [:all, :random, :periodic]
      default :all
      public? true
    end
    attribute :frequency_value, :decimal, public?: true
    attribute :norm_value, :decimal, public?: true
    attribute :tolerance_min, :decimal, public?: true
    attribute :tolerance_max, :decimal, public?: true
    attribute :instructions, :string, public?: true
    attribute :failure_action, :atom do
      allow_nil? false
      constraints one_of: [:block, :warn]
      default :warn
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :product_ids, UniboV4.Quality.Product do
      public? true
      through UniboV4.Quality.QualityPointProductLink
    end
    belongs_to :work_order_operation, UniboV4.Quality.WorkOrderOperation do
      public? true
    end
    belongs_to :team, UniboV4.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboV4.Quality.User do
      public? true
    end
    belongs_to :worksheet_template, UniboV4.Quality.WorksheetTemplate do
      public? true
    end
    belongs_to :company, UniboV4.Quality.Company do
      public? true
      allow_nil? false
    end
    has_many :checks, UniboV4.Quality.QualityCheck do
      public? true
      destination_attribute :point_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :operation_type, :check_type, :control_per, :control_frequency, :frequency_value, :norm_value, :tolerance_min, :tolerance_max, :instructions, :failure_action, :active]
      argument :company_id, :uuid, allow_nil?: false
      argument :team_id, :uuid
      argument :responsible_id, :uuid
      argument :worksheet_template_id, :uuid
      argument :product_ids, {:array, :string}
      argument :work_order_operation_id, :uuid
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:title)
      validate present(:operation_type)
      validate present(:check_type)
      # TODO: 不支持的 action 内校验规则 conditional_present
      # TODO: 不支持的 action 内校验规则 conditional_present
      # TODO: 不支持的 action 内校验规则 conditional_present
      # TODO: 不支持的 action 内校验规则 conditional_present
      # TODO: 不支持的 action 内校验规则 conditional_allowed
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
      accept [:title, :operation_type, :check_type, :control_per, :control_frequency, :frequency_value, :norm_value, :tolerance_min, :tolerance_max, :instructions, :failure_action, :active]
      # skipped: validate conditional_present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate conditional_allowed :work_order_operation_id (incompatible with bulk update atomic path)
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
    update :activate do
      accept []
      # skipped: validate conditional_present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate conditional_allowed :work_order_operation_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有已禁用的控制点可以启用"
      change set_attribute(:active, true)
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
    update :deactivate do
      accept []
      # skipped: validate conditional_present :norm_value (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_min (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :tolerance_max (incompatible with bulk update atomic path)
      # skipped: validate conditional_present :worksheet_template_id (incompatible with bulk update atomic path)
      # skipped: validate conditional_allowed :work_order_operation_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有已启用的控制点可以禁用"
      change set_attribute(:active, false)
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
    action :trigger_checks do
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
