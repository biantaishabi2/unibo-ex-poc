defmodule UniboV4.Blog.BlogTag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "blog_tags"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  relationships do
    belongs_to :blog_post, UniboV4.Blog.BlogPost do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
