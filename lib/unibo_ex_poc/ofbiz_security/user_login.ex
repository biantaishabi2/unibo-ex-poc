defmodule UniboExPoc.Ofbiz.Security.UserLogin do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "User Login"
  end

  postgres do
    table "security_user_logins"
    repo UniboExPoc.Repo
  end

  graphql do
    type :security_user_login

    queries do
      get :get_security_user_login, :read
      list :list_security_user_logins, :read
    end

    mutations do
      create :create_security_user_login, :create
      update :update_security_user_login, :update
      destroy :delete_security_user_login, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :user_login_id, :string, public?: true
    attribute :current_password, :string, public?: true
    attribute :password_hint, :string, public?: true
    attribute :is_system, :boolean, public?: true
    attribute :enabled, :boolean, public?: true
    attribute :has_logged_out, :boolean, public?: true
    attribute :require_password_change, :boolean, public?: true
    attribute :last_currency_uom, :string, public?: true
    attribute :last_locale, :string, public?: true
    attribute :last_time_zone, :string, public?: true
    attribute :disabled_date_time, :utc_datetime, public?: true
    attribute :successive_failed_logins, :integer, public?: true
    attribute :external_auth_id, :string do
      public? true
      description "For use with external authentication; the userLdapDn should be replaced with this"
    end
    attribute :user_ldap_dn, :string do
      public? true
      description "The user's LDAP Distinguished Name - used for LDAP authentication"
    end
    attribute :disabled_by, :string, public?: true
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
