defmodule UniboExPoc.Analytic.JournalEntryLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "凭证分录行占位实体（跨域引用 Accounting 域，最小字段）"
  end

  postgres do
    table "analytic_journal_entry_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :analytic_journal_entry_line

    queries do
      get :get_analytic_journal_entry_line, :read
      list :list_analytic_journal_entry_lines, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
