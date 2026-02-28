defmodule UniboV4.CRM.ContactPhone do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "contact_phones"
    repo UniboV4.Repo
  end

  graphql do
    type :contact_phone

    mutations do
      create :create_contact_phone, :create
      update :update_contact_phone, :update
      destroy :delete_contact_phone, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :phone_type, :atom do
      constraints one_of: [:mobile, :work, :home, :fax, :other]
      default :mobile
    end
    attribute :phone_number, :string, allow_nil?: false
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
      accept [:phone_type, :phone_number, :is_primary]
      argument :contact_id, :uuid, allow_nil?: false
      change manage_relationship(:contact_id, :contact, type: :append, on_lookup: :relate)
      validate present(:phone_number)
    end
    update :update do
      primary? true
      accept [:phone_type, :phone_number, :is_primary]
    end
  end

end
