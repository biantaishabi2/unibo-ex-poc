defmodule UniboExPoc.Ofbiz.Party.ContactMechAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_contact_mech_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_contact_mech_attribute

    queries do
      get :get_party_contact_mech_attribute, :read
      list :list_party_contact_mech_attributes, :read
    end

    mutations do
      create :create_party_contact_mech_attribute, :create
      update :update_party_contact_mech_attribute, :update
      destroy :delete_party_contact_mech_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "属性名"
    end
    attribute :attr_value, :string do
      public? true
      description "属性值"
    end
    attribute :attr_description, :string do
      public? true
      description "属性说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
