defmodule UniboExPoc.Ofbiz.Security.SecurityPermission do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Security Component - Security Permission"
  end

  postgres do
    table "security_permissions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :security_security_permission

    queries do
      get :get_security_security_permission, :read
      list :list_security_security_permissions, :read
    end

    mutations do
      create :create_security_security_permission, :create
      update :update_security_security_permission, :update
      destroy :delete_security_security_permission, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :permission_id, :string, public?: true
    attribute :description, :string, public?: true
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
