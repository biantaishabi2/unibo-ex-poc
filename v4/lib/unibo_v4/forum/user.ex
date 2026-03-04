defmodule UniboV4.Forum.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "forum_users"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :karma, :integer do
      default 0
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
