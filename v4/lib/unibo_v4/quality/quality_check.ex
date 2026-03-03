# Workflow: quality_check_lifecycle — 质量检查生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> do_pass
#   create --> do_fail
#   do_pass --> [*]
#   do_fail --> [*]
# ```
defmodule UniboV4.Quality.QualityCheck do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Quality.QualityCheck.Notifier]

  postgres do
    table "quality_checks"
    repo UniboV4.Repo
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
    end
    attribute :check_type, :atom do
      allow_nil? false
      constraints one_of: [:pass_fail, :measure, :picture, :instructions, :worksheet, :print_label]
      public? true
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:todo, :pass, :fail]
      default :todo
      public? true
    end
    attribute :qty_inspected, :decimal, public?: true
    attribute :measure_value, :decimal, public?: true
    attribute :picture, :string, public?: true
    attribute :worksheet_data, :map, public?: true
    attribute :note, :string, public?: true
    attribute :ref_type, :string, public?: true
    attribute :ref_id, :integer, public?: true
    attribute :checked_at, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :measure_success
  end

  relationships do
    belongs_to :point, UniboV4.Quality.QualityPoint do
      public? true
    end
    belongs_to :product, UniboV4.Quality.Product do
      public? true
      allow_nil? false
    end
    belongs_to :lot, UniboV4.Quality.Lot do
      public? true
    end
    belongs_to :team, UniboV4.Quality.QualityTeam do
      public? true
    end
    belongs_to :responsible, UniboV4.Quality.User do
      public? true
    end
    has_many :alerts, UniboV4.Quality.QualityAlert do
      public? true
      destination_attribute :check_id
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :do_pass do
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
    update :do_fail do
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
  end

end
