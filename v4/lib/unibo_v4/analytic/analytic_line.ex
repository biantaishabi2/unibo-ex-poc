# Workflow: analytic_line_manual — 手动分析行录入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Analytic.AnalyticLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Analytic.AnalyticLine.Notifier]

  postgres do
    table "analytic_lines"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :unit_amount, :decimal do
      default 0
      public? true
    end
    attribute :auto_generated, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, UniboV4.Analytic.AnalyticAccount do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Analytic.Partner do
      public? true
    end
    belongs_to :move_line, UniboV4.Analytic.JournalEntryLine do
      public? true
    end
    belongs_to :currency, UniboV4.Analytic.Currency do
      public? true
    end
    belongs_to :product, UniboV4.Analytic.Product do
      public? true
    end
    belongs_to :employee, UniboV4.Analytic.Employee do
      public? true
    end
    belongs_to :company, UniboV4.Analytic.Company do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :name, :amount, :unit_amount]
      argument :account_id, :uuid, allow_nil?: false
      change manage_relationship(:account_id, :account, type: :append, on_lookup: :relate)
      validate present(:date)
      validate present(:name)
      validate present(:amount)
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
      accept [:date, :name, :amount, :unit_amount]
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
    destroy :destroy do
      primary? true
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
  end

end
