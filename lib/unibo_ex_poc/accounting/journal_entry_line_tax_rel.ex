defmodule UniboV4.Accounting.JournalEntryLineTaxRel do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "分录行与税率的关联占位实体"
  end

  postgres do
    table "accounting_journal_entry_line_tax_rels"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_journal_entry_line_tax_rel

    queries do
      get :get_accounting_journal_entry_line_tax_rel, :read
      list :list_accounting_journal_entry_line_tax_rels, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :journal_entry_line, UniboV4.Accounting.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboV4.Accounting.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
