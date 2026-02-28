defmodule UniboV4.Marketing.Segment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "segments"
    repo UniboV4.Repo
  end

  graphql do
    type :segment

    queries do
      get :get_segment, :read
      list :list_segments, :read
    end

    mutations do
      create :create_segment, :create
      update :update_segment, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string
    attribute :criteria, :string
    attribute :member_count, :integer, default: 0
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :criteria]
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :description, :criteria, :member_count]
    end
  end

end
