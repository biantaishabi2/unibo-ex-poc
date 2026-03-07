defmodule UniboExPoc.Ofbiz.Order.OldOrderBlacklist do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_old_order_blacklists"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_old_order_blacklist

    queries do
      get :get_order_old_order_blacklist, :read
      list :list_order_old_order_blacklists, :read
    end

    mutations do
      create :create_order_old_order_blacklist, :create
      update :update_order_old_order_blacklist, :update
      destroy :delete_order_old_order_blacklist, :destroy
    end

  end

  attributes do
    attribute :blacklist_string, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_blacklist_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :old_order_blacklist_type, UniboExPoc.Ofbiz.Order.OldOrderBlacklistType do
      public? true
      source_attribute :order_blacklist_type_id
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
