defmodule UniboExPoc.Ofbiz.Common.SystemProperty do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Defines a System Property"
  end

  postgres do
    table "common_system_propertys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_system_property

    queries do
      get :get_common_system_property, :read
      list :list_common_system_propertys, :read
    end

    mutations do
      create :create_common_system_property, :create
      update :update_common_system_property, :update
      destroy :delete_common_system_property, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :system_resource_id, :string, public?: true
    attribute :system_property_id, :string, public?: true
    attribute :system_property_value, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  identities do
    identity :unique_system_property, [:system_resource_id, :system_property_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
