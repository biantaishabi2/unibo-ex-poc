defmodule UniboV4.Ofbiz.Security.UserLoginPasswordHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "User Login Password History"
  end

  postgres do
    table "security_user_login_password_historys"
    repo UniboV4.Repo
  end

  graphql do
    type :security_user_login_password_history

    queries do
      get :get_security_user_login_password_history, :read
      list :list_security_user_login_password_historys, :read
    end

    mutations do
      create :create_security_user_login_password_history, :create
      update :update_security_user_login_password_history, :update
      destroy :delete_security_user_login_password_history, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :current_password, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user_login, UniboV4.Ofbiz.Security.UserLogin do
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
