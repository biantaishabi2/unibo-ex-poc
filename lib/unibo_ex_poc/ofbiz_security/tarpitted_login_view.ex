defmodule UniboV4.Ofbiz.Security.TarpittedLoginView do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Login View couple currently tarpitted : any access to the view for the login is denied"
  end

  postgres do
    table "security_tarpitted_login_views"
    repo UniboV4.Repo
  end

  graphql do
    type :security_tarpitted_login_view

    queries do
      get :get_security_tarpitted_login_view, :read
      list :list_security_tarpitted_login_views, :read
    end

    mutations do
      create :create_security_tarpitted_login_view, :create
      update :update_security_tarpitted_login_view, :update
      destroy :delete_security_tarpitted_login_view, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :view_name_id, :string do
      public? true
      description "name of view protected from data theft"
    end
    attribute :user_login_id, :string, public?: true
    attribute :tarpit_release_date_time, :integer do
      public? true
      description "Date/Time at which the login will gain anew access to the view (in milliseconds from midnight, January 1, 1970 UTC , 0 meaning no tarpit to allow the admin to free a view and to keep history"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  identities do
    identity :unique_tarpit_login_view, [:view_name_id, :user_login_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
