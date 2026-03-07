defmodule UniboExPoc.Ofbiz.Order.ReturnStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_return_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_return_status

    queries do
      get :get_order_return_status, :read
      list :list_order_return_statuss, :read
    end

    mutations do
      create :create_order_return_status, :create
      update :update_order_return_status, :update
      destroy :delete_order_return_status, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_status_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :return_item_seq_id, :string, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :status_datetime, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_header, UniboExPoc.Ofbiz.Order.ReturnHeader do
      public? true
      source_attribute :return_id
      attribute_type :string
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
