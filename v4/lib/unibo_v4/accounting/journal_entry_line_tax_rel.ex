defmodule UniboV4.Accounting.JournalEntryLineTaxRel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "accounting_journal_entry_line_tax_rels"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
