defmodule UniboV4.Blog do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Blog.Blog
    resource UniboV4.Blog.Blog.Version
    resource UniboV4.Blog.BlogPost
    resource UniboV4.Blog.BlogPost.Version
    resource UniboV4.Blog.Visitor
    resource UniboV4.Blog.Visitor.Version
    resource UniboV4.Blog.BlogTag
    resource UniboV4.Blog.WebsiteTrack
    resource UniboV4.Blog.WebSite
    resource UniboV4.Blog.Party
  end
end
