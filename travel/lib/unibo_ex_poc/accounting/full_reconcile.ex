# Workflow: full_reconcile_lifecycle — 完全核销生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Accounting.FullReconcile do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "完全核销组，当一组行的 amount_residual 全部归零时创建 [R-REC-003]"
  end

  postgres do
    table "accounting_full_reconciles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_full_reconcile

    queries do
      get :get_accounting_full_reconcile, :read
      list :list_accounting_full_reconciles, :read
    end

    mutations do
      create :create_accounting_full_reconcile, :create
      destroy :delete_accounting_full_reconcile, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :partial_reconciles, UniboExPoc.Accounting.PartialReconcile do
      public? true
    end
    has_many :reconciled_lines, UniboExPoc.Accounting.JournalEntryLine do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept []
      # validation: all_residuals_zero
      change UniboExPoc.Accounting.Changes.FullReconcile.CreateCall1
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:partial_reconciles, :reconciled_lines]
  end

end
