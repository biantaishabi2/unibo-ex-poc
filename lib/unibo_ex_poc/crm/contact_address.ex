defmodule UniboV4.CRM.ContactAddress do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "联系地址，合并时地址字段整组同步(all-or-nothing)"
  end

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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
      validate present(:contact_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:address_type, :street, :city, :state, :postal_code, :country, :is_primary]
      # skipped: validate relationship_required :contact_id (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
