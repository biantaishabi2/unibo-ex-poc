defmodule UniboExPoc.Ofbiz.Marketing.TrackingCodeOrderReturn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_tracking_code_order_returns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_tracking_code_order_return

    queries do
      get :get_marketing_tracking_code_order_return, :read
      list :list_marketing_tracking_code_order_returns, :read
    end

    mutations do
      create :create_marketing_tracking_code_order_return, :create
      update :update_marketing_tracking_code_order_return, :update
      destroy :delete_marketing_tracking_code_order_return, :destroy
    end

  end

  attributes do
    attribute :return_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string, public?: true
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

  archive do
  end

end
