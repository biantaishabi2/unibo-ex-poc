defmodule UniboV4.Ofbiz.Security.SecurityGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Security Component - Security Group"
  end

  postgres do
    table "security_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :security_security_group

    queries do
      get :get_security_security_group, :read
      list :list_security_security_groups, :read
    end

    mutations do
      create :create_security_security_group, :create
      update :update_security_security_group, :update
      destroy :delete_security_security_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :group_id, :string, public?: true
    attribute :group_name, :string, public?: true
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
