defmodule UniboExPoc.Ofbiz.Order.RequirementStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_requirement_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_requirement_status

    queries do
      get :get_order_requirement_status, :read
      list :list_order_requirement_statuss, :read
    end

    mutations do
      create :create_order_requirement_status, :create
      update :update_order_requirement_status, :update
      destroy :delete_order_requirement_status, :destroy
    end

  end

  attributes do
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :status_date, :utc_datetime, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :requirement, UniboExPoc.Ofbiz.Order.Requirement do
      public? true
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
