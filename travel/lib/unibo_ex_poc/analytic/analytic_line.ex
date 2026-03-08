# Workflow: analytic_line_manual — 手动分析行录入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Analytic.AnalyticLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Analytic.AnalyticLine.Notifier]

  resource do
    description "分析行，记录某一时点在某分析账户下发生的成本/收入金额；可由 JournalEntryLine 自动生成，也可手动录入"
  end

  postgres do
    table "analytic_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :analytic_analytic_line

    queries do
      get :get_analytic_analytic_line, :read
      list :list_analytic_analytic_lines, :read
    end

    mutations do
      create :create_analytic_analytic_line, :create
      update :update_analytic_analytic_line, :update
      destroy :delete_analytic_analytic_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      public? true
      description "发生日期 [R-ANL-005]"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "摘要（来自 AcctgTransEntry.description）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "金额，正值=收入/借方，负值=成本/贷方 [R-ANL-006]
来自 AcctgTransEntry.amount（借贷方向由符号表示）
"
    end
    attribute :unit_amount, :decimal do
      default 0
      public? true
      description "数量（用于工时/工单场景，配合 product_uom_id 使用）"
    end
    attribute :auto_generated, :boolean do
      default false
      public? true
      description "是否由系统自动生成（过账时从 JournalEntryLine 的 analytic_distribution 展开）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :account, UniboExPoc.Analytic.AnalyticAccount do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Analytic.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :move_line, UniboExPoc.Analytic.JournalEntryLine do
      public? true
    end
    belongs_to :currency, UniboExPoc.Analytic.Currency do
      public? true
    end
    belongs_to :product, UniboExPoc.Analytic.Product do
      public? true
    end
    belongs_to :employee, UniboExPoc.Analytic.Employee do
      public? true
    end
    belongs_to :company, UniboExPoc.Analytic.Party do
      public? true
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :name, :amount, :unit_amount, :account_id, :currency_id, :product_id, :employee_id]
      argument :partner_id, :uuid
      argument :account_id, :uuid, allow_nil?: false
      change manage_relationship(:account_id, :account, type: :append, on_lookup: :relate)
      validate present(:date)
      validate present(:name)
      validate present(:amount)
      # validation: active_account_required
      validate compare(:date, greater_than: :account_start_date)
      change UniboExPoc.Analytic.Changes.AnalyticLine.CreateCall1
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
      description "仅手动行（auto_generated=false）可修改"
      primary? true
      accept [:date, :name, :amount, :unit_amount]
      argument :partner_id, :uuid
      # skipped: validate compare :date (incompatible with bulk update atomic path)
      change UniboExPoc.Analytic.Changes.AnalyticLine.UpdateCall1
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
    destroy :destroy do
      description "删除前检查关联 JournalEntryLine 是否已过账 [R-ANL-007]"
      primary? true
      # validation: no_delete_when_posted
      change UniboExPoc.Analytic.Changes.AnalyticLine.DestroyCall1
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
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
