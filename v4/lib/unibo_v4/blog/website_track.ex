defmodule UniboV4.Blog.WebsiteTrack do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "blog_website_tracks"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :page_url, :string, public?: true
  end

  relationships do
    belongs_to :visitor, UniboV4.Blog.Visitor do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
