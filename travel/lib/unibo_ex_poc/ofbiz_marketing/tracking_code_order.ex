defmodule UniboExPoc.Ofbiz.Marketing.TrackingCodeOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_tracking_code_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_tracking_code_order

    queries do
      get :get_marketing_tracking_code_order, :read
      list :list_marketing_tracking_code_orders, :read
    end

    mutations do
      create :create_marketing_tracking_code_order, :create
      update :update_marketing_tracking_code_order, :update
      destroy :delete_marketing_tracking_code_order, :destroy
    end

  end

  attributes do
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :is_billable, :boolean, public?: true
    attribute :site_id, :string, public?: true
    attribute :has_exported, :boolean, public?: true
    attribute :affiliate_referred_time_stamp, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tracking_code, UniboExPoc.Ofbiz.Marketing.TrackingCode do
      public? true
    end
    belongs_to :tracking_code_type, UniboExPoc.Ofbiz.Marketing.TrackingCodeType do
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
