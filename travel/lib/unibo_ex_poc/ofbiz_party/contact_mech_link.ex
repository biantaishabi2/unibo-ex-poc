defmodule UniboExPoc.Ofbiz.Party.ContactMechLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_contact_mech_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_contact_mech_link

    queries do
      get :get_party_contact_mech_link, :read
      list :list_party_contact_mech_links, :read
    end

    mutations do
      create :create_party_contact_mech_link, :create
      update :update_party_contact_mech_link, :update
      destroy :delete_party_contact_mech_link, :destroy
    end

  end

  attributes do
    attribute :contact_mech_id_from, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "来源联系方式编号"
    end
    attribute :contact_mech_id_to, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "目标联系方式编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_from
      define_attribute? false
    end
    belongs_to :to_contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
      source_attribute :contact_mech_id_to
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
