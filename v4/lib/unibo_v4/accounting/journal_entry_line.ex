defmodule UniboV4.Accounting.JournalEntryLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "journal_entry_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :journal_entry_line

    mutations do
      create :create_journal_entry_line, :create
      update :update_journal_entry_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :debit_amount, :decimal, default: 0
    attribute :credit_amount, :decimal, default: 0
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :journal_entry, UniboV4.Accounting.JournalEntry do
      allow_nil? false
    end
    belongs_to :gl_account, UniboV4.Accounting.GlAccount do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:debit_amount, :credit_amount, :description]
      argument :gl_account_id, :uuid, allow_nil?: false
      argument :journal_entry_id, :uuid, allow_nil?: false
      change manage_relationship(:journal_entry_id, :journal_entry, type: :append, on_lookup: :relate)
      change manage_relationship(:gl_account_id, :gl_account, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:debit_amount, :credit_amount, :description]
    end
  end

  validations do
    validate compare(:debit_amount, greater_than_or_equal_to: 0)
    validate compare(:credit_amount, greater_than_or_equal_to: 0)
  end

end
