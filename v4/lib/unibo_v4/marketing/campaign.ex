defmodule UniboV4.Marketing.Campaign do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Marketing.Campaign.Notifier]

  postgres do
    table "campaigns"
    repo UniboV4.Repo
  end

  graphql do
    type :campaign

    queries do
      get :get_campaign, :read
      list :list_campaigns, :read
    end

    mutations do
      create :create_campaign, :create
      update :update_campaign, :update
      update :launch_campaign, :launch
      update :complete_campaign, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :campaign_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :running, :paused, :completed, :cancelled]
      default :draft
        public? true
    end
    attribute :campaign_type, :atom do
      constraints one_of: [:email, :social, :event, :promotion, :other]
      default :email
        public? true
    end
    attribute :start_date, :date, public?: true
    attribute :end_date, :date, public?: true
    attribute :budget, :decimal, public?: true
    attribute :actual_cost, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :roles, UniboV4.Marketing.CampaignRole
    belongs_to :created_by, UniboV4.Accounts.User, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:campaign_code, :name, :campaign_type, :start_date, :end_date, :budget, :description]
      validate present(:campaign_code)
      validate present(:name)
      change relate_actor(:created_by)
    end
    update :update do
      primary? true
      accept [:name, :status, :start_date, :end_date, :budget, :actual_cost, :description]
    end
    update :launch do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以启动"
      end
      change set_attribute(:status, :running)
    end
    update :complete do
      accept [:actual_cost]
      validate attribute_equals(:status, :running) do
        message "只有运行中状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

  identities do
    identity :unique_campaign_code, [:campaign_code]
  end

end
