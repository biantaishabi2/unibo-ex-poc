defmodule UniboV4.Forum do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Forum.Forum
    resource UniboV4.Forum.Forum.Version
    resource UniboV4.Forum.Post
    resource UniboV4.Forum.Post.Version
    resource UniboV4.Forum.Vote
    resource UniboV4.Forum.Vote.Version
    resource UniboV4.Forum.Tag
    resource UniboV4.Forum.Tag.Version
    resource UniboV4.Forum.PostTagLink
    resource UniboV4.Forum.PostFavoriteLink
    resource UniboV4.Forum.Party
  end
end
