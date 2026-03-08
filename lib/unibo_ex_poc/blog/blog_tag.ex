defmodule UniboV4.Blog.BlogTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文章标签占位实体"
  end

  postgres do
    table "blog_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :blog_blog_tag

    queries do
      get :get_blog_blog_tag, :read
      list :list_blog_blog_tags, :read
    end

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
    defaults [:read, :update]
  end

end
