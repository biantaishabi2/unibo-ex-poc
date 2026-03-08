defmodule UniboV4.Ofbiz.Security.UserLoginSecurityGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Maps a UserLogin to a security group"
  end

  postgres do
    table "security_user_login_security_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :security_user_login_security_group

    queries do
      get :get_security_user_login_security_group, :read
      list :list_security_user_login_security_groups, :read
    end

    mutations do
      create :create_security_user_login_security_group, :create
      update :update_security_user_login_security_group, :update
      destroy :delete_security_user_login_security_group, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user_login, UniboV4.Ofbiz.Security.UserLogin do
      public? true
    end
    belongs_to :security_group, UniboV4.Ofbiz.Security.SecurityGroup do
      public? true
      source_attribute :group_id
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
