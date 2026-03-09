defmodule UniboExPoc.Ofbiz.Security.UserLoginSession do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "User Login History"
  end

  postgres do
    table "security_user_login_sessions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :security_user_login_session

    queries do
      get :get_security_user_login_session, :read
      list :list_security_user_login_sessions, :read
    end

    mutations do
      create :create_security_user_login_session, :create
      update :update_security_user_login_session, :update
      destroy :delete_security_user_login_session, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :saved_date, :utc_datetime, public?: true
    attribute :session_data, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user_login, UniboExPoc.Ofbiz.Security.UserLogin do
      public? true
    end
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
