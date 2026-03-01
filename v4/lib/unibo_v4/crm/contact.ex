defmodule UniboV4.CRM.Contact do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_contacts"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_contact

    queries do
      get :get_crm_contact, :read
      list :list_crm_contacts, :read
    end

    mutations do
      create :create_crm_contact, :create
      update :update_crm_contact, :update
      destroy :delete_crm_contact, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :email, :string, public?: true
    attribute :phone, :string, public?: true
    attribute :mobile, :string, public?: true
    attribute :company, :string, public?: true
    attribute :job_title, :string, public?: true
    attribute :contact_type, :atom do
      constraints one_of: [:individual, :company]
      default :individual
      public? true
    end
    attribute :tags, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :addresses, UniboV4.CRM.ContactAddress do
      public? true
    end
    has_many :phones, UniboV4.CRM.ContactPhone do
      public? true
    end
    has_many :leads, UniboV4.CRM.Lead do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :email, :phone, :mobile, :company, :job_title, :contact_type, :tags, :notes]
      validate present(:name)
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
      accept [:name, :email, :phone, :mobile, :company, :job_title, :contact_type, :tags, :notes]
      # TODO: 不支持的 change effect track_field_change
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
