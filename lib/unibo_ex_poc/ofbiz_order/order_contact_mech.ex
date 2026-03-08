defmodule UniboV4.Ofbiz.Order.OrderContactMech do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_contact_meches"
    repo UniboV4.Repo
  end

  graphql do
    type :order_order_contact_mech

    queries do
      get :get_order_order_contact_mech, :read
      list :list_order_order_contact_mechs, :read
    end

    mutations do
      create :create_order_order_contact_mech, :create
      update :update_order_order_contact_mech, :update
      destroy :delete_order_order_contact_mech, :destroy
    end

  end

  attributes do
    attribute :contact_mech_purpose_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboV4.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
