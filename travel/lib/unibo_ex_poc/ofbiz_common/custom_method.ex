defmodule UniboExPoc.Ofbiz.Common.CustomMethod do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Custom Method"
  end

  postgres do
    table "common_custom_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_custom_method

    queries do
      get :get_common_custom_method, :read
      list :list_common_custom_methods, :read
    end

    mutations do
      create :create_common_custom_method, :create
      update :update_common_custom_method, :update
      destroy :delete_common_custom_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :custom_method_id, :string, public?: true
    attribute :custom_method_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :custom_method_type, UniboExPoc.Ofbiz.Common.CustomMethodType do
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
