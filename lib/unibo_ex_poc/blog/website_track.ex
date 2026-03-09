defmodule UniboExPoc.Blog.WebsiteTrack do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "访客轨迹占位实体"
  end

  postgres do
    table "blog_website_tracks"
    repo UniboExPoc.Repo
  end

  graphql do
    type :blog_website_track

    queries do
      get :get_blog_website_track, :read
      list :list_blog_website_tracks, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :page_url, :string, public?: true
  end

  relationships do
    belongs_to :visitor, UniboExPoc.Blog.Visitor do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
