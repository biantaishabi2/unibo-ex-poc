defmodule UniboExPoc.Ofbiz.Order.OldOrderBlacklistType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_old_order_blacklist_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_old_order_blacklist_type

    queries do
      get :get_order_old_order_blacklist_type, :read
      list :list_order_old_order_blacklist_types, :read
    end

    mutations do
      create :create_order_old_order_blacklist_type, :create
      update :update_order_old_order_blacklist_type, :update
      destroy :delete_order_old_order_blacklist_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_blacklist_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
