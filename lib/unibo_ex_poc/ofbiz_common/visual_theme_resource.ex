defmodule UniboV4.Ofbiz.Common.VisualThemeResource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "The VisualThemeResource entity contains visual theme
          resources. Each visual theme can have any number of resources."
  end

  postgres do
    table "common_visual_theme_resources"
    repo UniboV4.Repo
  end

  graphql do
    type :common_visual_theme_resource

    queries do
      get :get_common_visual_theme_resource, :read
      list :list_common_visual_theme_resources, :read
    end

    mutations do
      create :create_common_visual_theme_resource, :create
      update :update_common_visual_theme_resource, :update
      destroy :delete_common_visual_theme_resource, :destroy
    end

  end

  attributes do
    attribute :sequence_id, :string do
      primary_key? true
      allow_nil? false
      public? true
      description "Controls the loading order of duplicate resource types"
    end
    attribute :resource_value, :string do
      public? true
      description "Contains the resource value"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :visual_theme, UniboV4.Ofbiz.Common.VisualTheme do
      public? true
    end
    belongs_to :enumeration, UniboV4.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :resource_type_enum_id
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
