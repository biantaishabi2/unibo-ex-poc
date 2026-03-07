defmodule UniboExPoc.Ofbiz.Order.WorkReqFulfType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_work_req_fulf_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_work_req_fulf_type

    queries do
      get :get_order_work_req_fulf_type, :read
      list :list_order_work_req_fulf_types, :read
    end

    mutations do
      create :create_order_work_req_fulf_type, :create
      update :update_order_work_req_fulf_type, :update
      destroy :delete_order_work_req_fulf_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :work_req_fulf_type_id, :string, public?: true
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
