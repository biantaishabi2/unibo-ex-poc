defmodule UniboV4.Marketing.MailingList do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "mailing_lists"
    repo UniboV4.Repo
  end

  graphql do
    type :mailing_list

    queries do
      get :get_mailing_list, :read
      list :list_mailing_lists, :read
    end

    mutations do
      create :create_mailing_list, :create
      update :update_mailing_list, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboV4.Marketing.MailingListMember
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description]
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
  end

end
