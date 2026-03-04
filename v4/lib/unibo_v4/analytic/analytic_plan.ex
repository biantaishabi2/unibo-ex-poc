# Workflow: analytic_plan_lifecycle — 分析计划管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> update
#   update --> deactivate
#   deactivate --> [*]
# ```
defmodule UniboV4.Analytic.AnalyticPlan do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "analytic_plans"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :code, :string, public?: true
    attribute :description, :string, public?: true
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :default_applicability, :atom do
      constraints one_of: [:optional, :mandatory, :unavailable]
      default :optional
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :accounts, UniboV4.Analytic.AnalyticAccount do
      public? true
      destination_attribute :plan_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :description, :color, :default_applicability]
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
      accept [:name, :code, :description, :color, :default_applicability, :is_active]
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
      change set_attribute(:is_active, false)
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

  identities do
    identity :unique_plan_code, [:code]
  end

end
