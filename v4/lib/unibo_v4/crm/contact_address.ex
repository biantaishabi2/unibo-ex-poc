defmodule UniboV4.CRM.ContactAddress do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "contact_addresses"
    repo UniboV4.Repo
  end

  graphql do
    type :contact_address

    mutations do
      create :create_contact_address, :create
      update :update_contact_address, :update
      destroy :delete_contact_address, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :address_type, :atom do
      constraints one_of: [:home, :work, :shipping, :billing, :other]
      default :work
    end
    attribute :street, :string
    attribute :city, :string
    attribute :state, :string
    attribute :postal_code, :string
    attribute :country, :string, default: "CN"
    attribute :is_primary, :boolean, default: false
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact do
      allow_nil? false
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:address_type, :street, :city, :state, :postal_code, :country, :is_primary]
      argument :contact_id, :uuid, allow_nil?: false
      change manage_relationship(:contact_id, :contact, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:address_type, :street, :city, :state, :postal_code, :country, :is_primary]
    end
  end

end
