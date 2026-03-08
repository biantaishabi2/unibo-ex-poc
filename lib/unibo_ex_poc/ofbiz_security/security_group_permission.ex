defmodule UniboV4.Ofbiz.Security.SecurityGroupPermission do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Defines a permission available to a security group; there is no FK to SecurityPermission because we want to leave open the possibility of ad-hoc permissions, especially for the Entity Data Maintenance pages which have TONS of permissions"
  end

  postgres do
    table "security_group_permissions"
    repo UniboV4.Repo
  end

  graphql do
    type :security_security_group_permission

    queries do
      get :get_security_security_group_permission, :read
      list :list_security_security_group_permissions, :read
    end

    mutations do
      create :create_security_security_group_permission, :create
      update :update_security_security_group_permission, :update
      destroy :delete_security_security_group_permission, :destroy
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
    belongs_to :security_group, UniboV4.Ofbiz.Security.SecurityGroup do
      public? true
      source_attribute :group_id
    end
    belongs_to :security_permission, UniboV4.Ofbiz.Security.SecurityPermission do
      public? true
      source_attribute :permission_id
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
