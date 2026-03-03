# Workflow: analytic_distribution_setup — 分摊规则配置流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Analytic.Analytic.AnalyticDistribution do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Analytic.Analytic.AnalyticDistribution.Notifier]

  postgres do
    table "analytic_distributions"
    repo UniboV4.Repo
  end

  graphql do
    type :analytic_analytic_distribution

    queries do
      get :get_analytic_analytic_distribution, :read
      list :list_analytic_analytic_distributions, :read
    end

    mutations do
      create :create_analytic_analytic_distribution, :create
      update :update_analytic_analytic_distribution, :update
      destroy :delete_analytic_analytic_distribution, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :percentage, :decimal do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :move_line, UniboV4.Analytic.Analytic.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :account, UniboV4.Analytic.Analytic.AnalyticAccount do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:percentage]
      argument :move_line_id, :uuid, allow_nil?: false
      change manage_relationship(:move_line_id, :move_line, type: :append, on_lookup: :relate)
      argument :account_id, :uuid, allow_nil?: false
      change manage_relationship(:account_id, :account, type: :append, on_lookup: :relate)
      validate compare(:percentage, greater_than: 0, less_than_or_equal_to: 100)
      # message: "分摊百分比必须在 0~100 之间"
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect custom
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
      accept [:percentage]
      # skipped: validate compare :percentage (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
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
