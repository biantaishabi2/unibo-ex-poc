defmodule UniboV4.Analytic.Analytic.JournalEntryLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "analytic_journal_entry_lines"
    repo UniboV4.Repo
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
