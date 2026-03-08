defmodule UniboExPoc.Knowledge do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Knowledge.Article
    resource UniboExPoc.Knowledge.Article.Version
    resource UniboExPoc.Knowledge.ArticleMember
    resource UniboExPoc.Knowledge.ArticleMember.Version
    resource UniboExPoc.Knowledge.ArticleVersion
    resource UniboExPoc.Knowledge.Tag
    resource UniboExPoc.Knowledge.Tag.Version
    resource UniboExPoc.Knowledge.Favorite
    resource UniboExPoc.Knowledge.Favorite.Version
    resource UniboExPoc.Knowledge.ArticleTagLink
    resource UniboExPoc.Knowledge.Group
    resource UniboExPoc.Knowledge.Party
  end
end
