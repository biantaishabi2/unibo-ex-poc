defmodule UniboV4.Accounting.JournalEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.JournalEntry.Notifier]

  postgres do
    table "journal_entries"
    repo UniboV4.Repo
  end

  graphql do
    type :journal_entry

    queries do
      get :get_journal_entry, :read
      list :list_journal_entrys, :read
    end

    mutations do
      create :create_journal_entry, :create
      update :post_journal_entry, :post
      update :reverse_journal_entry, :reverse
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :entry_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :posted, :reversed]
      default :draft
    end
    attribute :entry_date, :date, allow_nil?: false
    attribute :description, :string
    attribute :total_debit, :decimal
    attribute :total_credit, :decimal
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :lines, UniboV4.Accounting.JournalEntryLine
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:entry_number, :entry_date, :description, :notes]
      argument :lines, {:array, :string}, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      validate present(:entry_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :post do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿凭证可以过账"
      end
      change set_attribute(:status, :posted)
    end
    update :reverse do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :posted) do
        message "只有已过账凭证可以冲销"
      end
      change set_attribute(:status, :reversed)
    end
  end

  identities do
    identity :unique_entry_number, [:entry_number]
  end

end
