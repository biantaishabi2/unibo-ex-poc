defmodule UniboV4.Communication.ChannelMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "channel_members"
    repo UniboV4.Repo
  end

  graphql do
    type :channel_member

    queries do
      get :get_channel_member, :read
      list :list_channel_members, :read
    end

    mutations do
      create :create_channel_member, :create
      destroy :delete_channel_member, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :atom do
      constraints one_of: [:admin, :member]
      default :member
    end
    attribute :joined_date, :date, allow_nil?: false
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :channel, UniboV4.Communication.Channel do
      allow_nil? false
    end
    belongs_to :user, UniboV4.Accounts.User do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role, :joined_date]
      argument :channel_id, :uuid, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
    end
  end

end
