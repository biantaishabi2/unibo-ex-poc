defmodule UniboV4.Communication.Channel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "channels"
    repo UniboV4.Repo
  end

  graphql do
    type :channel

    queries do
      get :get_channel, :read
      list :list_channels, :read
    end

    mutations do
      create :create_channel, :create
      update :update_channel, :update
      update :archive_channel, :archive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :channel_type, :atom do
      constraints one_of: [:public, :private, :direct]
      default :public
        public? true
    end
    attribute :description, :string, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboV4.Communication.ChannelMember
    has_many :messages, UniboV4.Communication.Message
    belongs_to :created_by, UniboV4.Accounts.User, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :channel_type, :description]
      validate present(:name)
      change relate_actor(:created_by)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
    update :archive do
      accept []
      validate attribute_equals(:is_active, true) do
        message "只有活跃频道可以归档"
      end
      change set_attribute(:is_active, :false)
    end
  end

end
