defmodule UniboExPoc.CRM.ContactPhone do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "联系电话"
  end

  postgres do
    table "crm_contact_phones"
    repo UniboExPoc.Repo
  end

  graphql do
    type :crm_contact_phone

    mutations do
      create :create_crm_contact_phone, :create
      update :update_crm_contact_phone, :update
      destroy :delete_crm_contact_phone, :destroy
    end

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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact, UniboExPoc.CRM.Contact do
      public? true
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:phone_type, :phone_number, :is_primary]
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
