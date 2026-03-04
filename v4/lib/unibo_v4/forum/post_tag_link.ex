defmodule UniboV4.Forum.PostTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "forum_post_tag_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :post, UniboV4.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboV4.Forum.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
