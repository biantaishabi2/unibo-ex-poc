defmodule UniboExPoc.Accounting.JournalEntryLineTaxRel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "分录行与税率的关联占位实体"
  end

  postgres do
    table "accounting_journal_entry_line_tax_rels"
    repo UniboExPoc.Repo
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
    belongs_to :journal_entry_line, UniboExPoc.Accounting.JournalEntryLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboExPoc.Accounting.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
