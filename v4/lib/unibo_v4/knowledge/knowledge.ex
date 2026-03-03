defmodule UniboV4.Knowledge do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Knowledge.Article
    resource UniboV4.Knowledge.ArticleMember
    resource UniboV4.Knowledge.ArticleVersion
    resource UniboV4.Knowledge.Tag
    resource UniboV4.Knowledge.Favorite
    resource UniboV4.Knowledge.ArticleTagLink
    resource UniboV4.Knowledge.User
    resource UniboV4.Knowledge.Group
  end
end
