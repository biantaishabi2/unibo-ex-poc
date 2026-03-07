defmodule UniboExPoc.Ofbiz.Accounting.GlJournal do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_journals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_journal

    queries do
      get :get_accounting_gl_journal, :read
      list :list_accounting_gl_journals, :read
    end

    mutations do
      create :create_accounting_gl_journal, :create
      update :update_accounting_gl_journal, :update
      destroy :delete_accounting_gl_journal, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_journal_id, :string, public?: true
    attribute :gl_journal_name, :string, public?: true
    attribute :organization_party_id, :string, public?: true
    attribute :is_posted, :boolean, public?: true
    attribute :posted_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
