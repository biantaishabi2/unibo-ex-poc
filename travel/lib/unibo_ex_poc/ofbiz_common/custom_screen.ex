defmodule UniboExPoc.Ofbiz.Common.CustomScreen do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Custom Screen"
  end

  postgres do
    table "common_custom_screens"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_custom_screen

    queries do
      get :get_common_custom_screen, :read
      list :list_common_custom_screens, :read
    end

    mutations do
      create :create_common_custom_screen, :create
      update :update_common_custom_screen, :update
      destroy :delete_common_custom_screen, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :custom_screen_id, :string, public?: true
    attribute :custom_screen_name, :string, public?: true
    attribute :custom_screen_location, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :custom_screen_type, UniboExPoc.Ofbiz.Common.CustomScreenType do
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
