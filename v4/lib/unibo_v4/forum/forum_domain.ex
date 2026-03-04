defmodule UniboV4.Forum do
  use Ash.Domain

  resources do
    resource UniboV4.Forum.Forum
    resource UniboV4.Forum.Post
    resource UniboV4.Forum.Vote
    resource UniboV4.Forum.Tag
    resource UniboV4.Forum.PostTagLink
    resource UniboV4.Forum.PostFavoriteLink
    resource UniboV4.Forum.User
  end
end
