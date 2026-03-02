defmodule UniboV4.POS.PosSession do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_sessions"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_session

    queries do
      get :get_pos_session, :read
      list :list_pos_sessions, :read
    end

    mutations do
      create :create_pos_session, :create
      update :open_pos_session, :open
      update :close_pos_session, :close
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :session_code, :string, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:opening, :open, :closing, :closed]
      default :opening
        public? true
    end
    attribute :opening_balance, :decimal, default: 0, public?: true
    attribute :closing_balance, :decimal, public?: true
    attribute :open_date, :utc_datetime, allow_nil?: false, public?: true
    attribute :close_date, :utc_datetime, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :orders, UniboV4.POS.PosOrder
    belongs_to :cashier, UniboV4.Accounts.User, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:session_code, :opening_balance, :open_date, :notes]
      validate present(:session_code)
      change relate_actor(:cashier)
    end
    update :open do
      accept []
      validate attribute_equals(:status, :opening) do
        message "只有开启中状态可以打开"
      end
      change set_attribute(:status, :open)
    end
    update :close do
      accept [:closing_balance]
      validate attribute_equals(:status, :open) do
        message "只有已打开状态可以关闭"
      end
      change set_attribute(:status, :closed)
    end
  end

  identities do
    identity :unique_session_code, [:session_code]
  end

end
