defmodule UniboExPoc.Ofbiz.Common.CustomMethodType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Custom Method Type"
  end

  postgres do
    table "common_custom_method_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_custom_method_type

    queries do
      get :get_common_custom_method_type, :read
      list :list_common_custom_method_types, :read
    end

    mutations do
      create :create_common_custom_method_type, :create
      update :update_common_custom_method_type, :update
      destroy :delete_common_custom_method_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :custom_method_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_custom_method_type, UniboExPoc.Ofbiz.Common.CustomMethodType do
      public? true
      source_attribute :parent_type_id
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
