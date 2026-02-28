defmodule UniboV4.Marketing.Event do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "events"
    repo UniboV4.Repo
  end

  graphql do
    type :event

    queries do
      get :get_event, :read
      list :list_events, :read
    end

    mutations do
      create :create_event, :create
      update :publish_event, :publish
      update :complete_event, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :event_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :published, :ongoing, :completed, :cancelled]
      default :draft
    end
    attribute :start_date, :utc_datetime
    attribute :end_date, :utc_datetime
    attribute :location, :string
    attribute :max_attendees, :integer
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :registrations, UniboV4.Marketing.EventRegistration
    belongs_to :campaign, UniboV4.Marketing.Campaign
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:event_code, :name, :start_date, :end_date, :location, :max_attendees, :description]
      argument :campaign_id, :uuid
      validate present(:event_code)
      validate present(:name)
    end
    update :publish do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以发布"
      end
      change set_attribute(:status, :published)
    end
    update :complete do
      accept []
      validate attribute_in(:status, [:published, :ongoing]) do
        message "只有已发布或进行中状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

  identities do
    identity :unique_event_code, [:event_code]
  end

end
