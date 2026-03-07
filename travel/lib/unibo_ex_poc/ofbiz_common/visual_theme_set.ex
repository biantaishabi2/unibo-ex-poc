defmodule UniboExPoc.Ofbiz.Common.VisualThemeSet do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Groups toghether Visual Themes that can be used for one (or a set of) application."
  end

  postgres do
    table "common_visual_theme_sets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_visual_theme_set

    queries do
      get :get_common_visual_theme_set, :read
      list :list_common_visual_theme_sets, :read
    end

    mutations do
      create :create_common_visual_theme_set, :create
      update :update_common_visual_theme_set, :update
      destroy :delete_common_visual_theme_set, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :visual_theme_set_id, :string, public?: true
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
