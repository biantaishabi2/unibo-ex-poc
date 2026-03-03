defmodule UniboV4.CRM.ContactAddress do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_contact_addresses"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_contact_address

    mutations do
      create :create_crm_contact_address, :create
      update :update_crm_contact_address, :update
      destroy :delete_crm_contact_address, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :address_type, :atom do
      constraints one_of: [:home, :work, :shipping, :billing, :other]
      default :work
      public? true
    end
    attribute :street, :string, public?: true
    attribute :city, :string, public?: true
    attribute :state, :string, public?: true
    attribute :postal_code, :string, public?: true
    attribute :country, :string do
      default "CN"
      public? true
    end
    attribute :is_primary, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact do
      public? true
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
      validate present(:contact_id)
      # TODO: 不支持的 action 内校验规则 belongs_to_exists
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:address_type, :street, :city, :state, :postal_code, :country, :is_primary]
      # skipped: validate belongs_to_exists :contact_id (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
