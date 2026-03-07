defmodule UniboExPoc.Ofbiz.Common.CustomScreenType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Custom Screen Type"
  end

  postgres do
    table "common_custom_screen_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_custom_screen_type

    queries do
      get :get_common_custom_screen_type, :read
      list :list_common_custom_screen_types, :read
    end

    mutations do
      create :create_common_custom_screen_type, :create
      update :update_common_custom_screen_type, :update
      destroy :delete_common_custom_screen_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :custom_screen_type_id, :string, public?: true
    attribute :parent_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :child_custom_screen_type, UniboExPoc.Ofbiz.Common.CustomScreenType do
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
    archive_related [:child_custom_screen_type]
  end

end
