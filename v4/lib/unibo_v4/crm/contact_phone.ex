defmodule UniboV4.CRM.ContactPhone do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "crm_contact_phones"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :phone_type, :atom do
      constraints one_of: [:mobile, :work, :home, :fax, :other]
      default :mobile
      public? true
    end
    attribute :phone_number, :string do
      allow_nil? false
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
    defaults [:destroy]
    create :create do
      primary? true
      accept [:phone_type, :phone_number, :is_primary]
      argument :contact_id, :uuid, allow_nil?: false
      change manage_relationship(:contact_id, :contact, type: :append, on_lookup: :relate)
      validate present(:phone_number)
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
      accept [:phone_type, :phone_number, :is_primary]
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
