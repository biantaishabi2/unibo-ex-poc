defmodule UniboV4.Blog do
  use Ash.Domain

  resources do
    resource UniboV4.Blog.Blog
    resource UniboV4.Blog.BlogPost
    resource UniboV4.Blog.WebPage
    resource UniboV4.Blog.Visitor
    resource UniboV4.Blog.BlogTag
    resource UniboV4.Blog.WebsiteTrack
    resource UniboV4.Blog.User
    resource UniboV4.Blog.Website
  end
end
