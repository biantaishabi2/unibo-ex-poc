defmodule UniboV4.CRM.Contact do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "contacts"
    repo UniboV4.Repo
  end

  graphql do
    type :contact

    queries do
      get :get_contact, :read
      list :list_contacts, :read
    end

    mutations do
      create :create_contact, :create
      update :update_contact, :update
      destroy :delete_contact, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :email, :string
    attribute :company, :string
    attribute :job_title, :string
    attribute :contact_type, :atom do
      constraints one_of: [:individual, :company]
      default :individual
    end
    attribute :tags, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :addresses, UniboV4.CRM.ContactAddress
    has_many :phones, UniboV4.CRM.ContactPhone
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :email, :company, :job_title, :contact_type, :tags, :notes]
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :email, :company, :job_title, :contact_type, :tags, :notes]
    end
  end

end
