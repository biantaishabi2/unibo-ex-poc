defmodule UniboExPoc.Ofbiz.Common.VisualTheme do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "The VisualTheme entity contains one entry per visual theme."
  end

  postgres do
    table "common_visual_themes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_visual_theme

    queries do
      get :get_common_visual_theme, :read
      list :list_common_visual_themes, :read
    end

    mutations do
      create :create_common_visual_theme, :create
      update :update_common_visual_theme, :update
      destroy :delete_common_visual_theme, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :visual_theme_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :visual_theme_set, UniboExPoc.Ofbiz.Common.VisualThemeSet do
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
