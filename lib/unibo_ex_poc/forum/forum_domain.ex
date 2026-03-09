defmodule UniboExPoc.Forum do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Forum.Forum
    resource UniboExPoc.Forum.Forum.Version
    resource UniboExPoc.Forum.Post
    resource UniboExPoc.Forum.Post.Version
    resource UniboExPoc.Forum.Vote
    resource UniboExPoc.Forum.Vote.Version
    resource UniboExPoc.Forum.Tag
    resource UniboExPoc.Forum.Tag.Version
    resource UniboExPoc.Forum.PostTagLink
    resource UniboExPoc.Forum.PostFavoriteLink
    resource UniboExPoc.Forum.Party
  end
end
