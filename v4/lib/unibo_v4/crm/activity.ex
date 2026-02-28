defmodule UniboV4.CRM.Activity do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "activities"
    repo UniboV4.Repo
  end

  graphql do
    type :activity

    queries do
      get :get_activity, :read
      list :list_activitys, :read
    end

    mutations do
      create :create_activity, :create
      update :update_activity, :update
      update :complete_activity, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :activity_type, :atom do
      allow_nil? false
      constraints one_of: [:phone_call, :email, :meeting, :note, :other]
    end
    attribute :subject, :string, allow_nil?: false
    attribute :description, :string
    attribute :activity_date, :utc_datetime, allow_nil?: false
    attribute :duration_minutes, :integer
    attribute :status, :atom do
      constraints one_of: [:planned, :completed, :cancelled]
      default :planned
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact
    belongs_to :lead, UniboV4.CRM.Lead
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:activity_type, :subject, :description, :activity_date, :duration_minutes]
      argument :contact_id, :uuid
      argument :lead_id, :uuid
      validate present(:subject)
      change relate_actor(:created_by)
    end
    update :update do
      primary? true
      accept [:subject, :description, :activity_date, :duration_minutes, :status]
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :planned) do
        message "只有计划中的活动可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

end
