defmodule UniboExPoc.Ofbiz.Content.WebSitePublishPoint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_web_site_publish_points"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_web_site_publish_point

    queries do
      get :get_content_web_site_publish_point, :read
      list :list_content_web_site_publish_points, :read
    end

    mutations do
      create :create_content_web_site_publish_point, :create
      update :update_content_web_site_publish_point, :update
      destroy :delete_content_web_site_publish_point, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :template_title, :string, public?: true
    attribute :style_sheet_file, :string, public?: true
    attribute :logo, :string, public?: true
    attribute :medallion_logo, :string, public?: true
    attribute :line_logo, :string, public?: true
    attribute :left_bar_id, :string, public?: true
    attribute :right_bar_id, :string, public?: true
    attribute :content_dept, :string, public?: true
    attribute :about_content_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
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
