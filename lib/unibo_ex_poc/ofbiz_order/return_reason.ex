defmodule UniboV4.Ofbiz.Order.ReturnReason do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_return_reasons"
    repo UniboV4.Repo
  end

  graphql do
    type :order_return_reason

    queries do
      get :get_order_return_reason, :read
      list :list_order_return_reasons, :read
    end

    mutations do
      create :create_order_return_reason, :create
      update :update_order_return_reason, :update
      destroy :delete_order_return_reason, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_reason_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :sequence_id, :string, public?: true
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
