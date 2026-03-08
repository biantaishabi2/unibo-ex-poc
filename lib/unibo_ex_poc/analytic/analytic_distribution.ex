# Workflow: analytic_distribution_setup — 分摊规则配置流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Analytic.AnalyticDistribution do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboV4.Analytic.AnalyticDistribution.Notifier]

  resource do
    description "分摊规则，将一笔金额按百分比自动分配到多个 AnalyticAccount；附加在 JournalEntryLine 上"
  end

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
      description "分摊百分比（0-100），所有 move_line_id 相同的记录合计必须=100 [R-ANL-004]"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :move_line, UniboV4.Analytic.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :account, UniboV4.Analytic.AnalyticAccount do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:move_line_id, :account_id, :percentage]
      argument :move_line_id, :uuid, allow_nil?: false
      change manage_relationship(:move_line_id, :move_line, type: :append, on_lookup: :relate)
      argument :account_id, :uuid, allow_nil?: false
      change manage_relationship(:account_id, :account, type: :append, on_lookup: :relate)
      validate compare(:percentage, greater_than: 0, less_than_or_equal_to: 100)
      # message: "分摊百分比必须在 0~100 之间"
      # validation: total_percentage_equals_100
      # validation: active_account_required
      change UniboV4.Analytic.Changes.AnalyticDistribution.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:percentage]
      # skipped: validate compare :percentage (incompatible with bulk update atomic path)
      # skipped: validate aggregate_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboV4.Analytic.Changes.AnalyticDistribution.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
