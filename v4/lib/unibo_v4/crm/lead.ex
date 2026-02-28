defmodule UniboV4.CRM.Lead do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.CRM.Lead.Notifier]

  postgres do
    table "leads"
    repo UniboV4.Repo
  end

  graphql do
    type :lead

    queries do
      get :get_lead, :read
      list :list_leads, :read
    end

    mutations do
      create :create_lead, :create
      update :update_lead, :update
      update :win_lead, :win
      update :lose_lead, :lose
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :expected_revenue, :decimal
    attribute :probability, :decimal
    attribute :status, :atom do
      constraints one_of: [:new, :qualified, :proposition, :negotiation, :won, :lost]
      default :new
    end
    attribute :source, :string
    attribute :expected_close_date, :date
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact
    belongs_to :stage, UniboV4.CRM.LeadStage
    belongs_to :assigned_to, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :expected_revenue, :probability, :source, :expected_close_date, :notes]
      argument :contact_id, :uuid
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :expected_revenue, :probability, :status, :source, :expected_close_date, :notes]
    end
    update :win do
      accept []
      validate attribute_in(:status, [:new, :qualified, :proposition, :negotiation]) do
        message "只有活跃商机可以赢单"
      end
      change set_attribute(:status, :won)
    end
    update :lose do
      accept []
      validate attribute_in(:status, [:new, :qualified, :proposition, :negotiation]) do
        message "只有活跃商机可以标记输单"
      end
      change set_attribute(:status, :lost)
    end
  end

end
