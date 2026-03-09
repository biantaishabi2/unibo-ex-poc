defmodule UniboExPoc.Blog do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Blog.Blog
    resource UniboExPoc.Blog.Blog.Version
    resource UniboExPoc.Blog.BlogPost
    resource UniboExPoc.Blog.BlogPost.Version
    resource UniboExPoc.Blog.Visitor
    resource UniboExPoc.Blog.Visitor.Version
    resource UniboExPoc.Blog.BlogTag
    resource UniboExPoc.Blog.WebsiteTrack
    resource UniboExPoc.Blog.WebSite
    resource UniboExPoc.Blog.Party
  end
end
