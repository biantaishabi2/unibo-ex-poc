# Workflow: quality_check_lifecycle — 质量检查生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> do_pass
#   create --> do_fail
#   do_pass --> [*]
#   do_fail --> [*]
# ```
defmodule UniboExPoc.Quality.QualityCheck do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Quality.QualityCheck.Notifier]

  resource do
    description "质量检查记录，包含状态机 todo→pass/fail，支持 6 种检查类型"
  end

  postgres do
    table "quality_checks"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_check

    queries do
      get :get_quality_quality_check, :read
      list :list_quality_quality_checks, :read
    end

    mutations do
      create :create_quality_quality_check, :create
      update :do_pass_quality_quality_check, :do_pass
      update :do_fail_quality_quality_check, :do_fail
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "检查编号（自动生成序列号）"
    end
    attribute :check_type, :atom do
      allow_nil? false
      constraints one_of: [:pass_fail, :measure, :picture, :instructions, :worksheet, :print_label]
      public? true
      description "检查类型，继承自 Point 或手动指定"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:todo, :pass, :fail]
      default :todo
      public? true
      description "检查状态"
    end
    attribute :qty_inspected, :decimal do
      public? true
      description "检验数量"
    end
    attribute :measure_value, :decimal do
      public? true
      description "实测值（仅 measure 类型）"
    end
    attribute :picture, :string do
      public? true
      description "拍照记录附件路径（仅 picture 类型）"
    end
    attribute :worksheet_data, :map do
      public? true
      description "工作表填写数据（jsonb）"
    end
    attribute :note, :string do
      public? true
      description "检查备注"
    end
    attribute :ref_type, :string do
      public? true
      description "多态关联类型：picking / production / workorder"
    end
    attribute :ref_id, :integer do
      public? true
      description "多态关联 ID"
    end
    attribute :checked_at, :utc_datetime do
      public? true
      description "检查完成时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :measure_success, :atom, {UniboExPoc.Quality.Calculations.QualityCheck.MeasureSuccess, []}
  end

  relationships do
    belongs_to :point, UniboExPoc.Quality.QualityPoint do
      public? true
    end
    belongs_to :product, UniboExPoc.Quality.Product do
      public? true
      allow_nil? false
    end
    belongs_to :lot, UniboExPoc.Quality.Lot do
      public? true
    end
    belongs_to :team, UniboExPoc.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboExPoc.Quality.Party do
      public? true
      source_attribute :responsible_party_id
    end
    has_many :alerts, UniboExPoc.Quality.QualityAlert do
      public? true
      destination_attribute :check_id
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
      accept [:check_type, :qty_inspected, :note, :ref_type, :ref_id]
      argument :product_id, :uuid, allow_nil?: false
      argument :company_id, :uuid, allow_nil?: false
      argument :point_id, :uuid
      argument :lot_id, :uuid
      argument :team_id, :uuid
      argument :responsible_id, :uuid
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:check_type)
      change set_attribute(:id, expr(id))
    end
    update :do_pass do
      description "执行检查——通过"
      primary? true
      accept [:measure_value, :picture, :worksheet_data, :note]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :todo do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :todo}))
        end
      end
      # message: "只有待检查状态可以标记通过"
      change set_attribute(:state, :pass)
      change UniboExPoc.Quality.Changes.QualityCheck.ComputeCheckedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :do_fail do
      description "执行检查——失败"
      accept [:measure_value, :picture, :worksheet_data, :note]
      argument :create_alert, :boolean
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :todo do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :todo}))
        end
      end
      # message: "只有待检查状态可以标记失败"
      change set_attribute(:state, :fail)
      change UniboExPoc.Quality.Changes.QualityCheck.ComputeCheckedAt
      change UniboExPoc.Quality.Changes.QualityCheck.DoFailCall5
      change UniboExPoc.Quality.Changes.QualityCheck.DoFailCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
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
    policy action_type(:update) do
      authorize_if expr(actor.role == :admin)
      authorize_if relates_to_actor_via(:company_party)
    end
  end

end
