defmodule UniboExPoc.Ofbiz.Marketing.TrackingCodeVisit do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "marketing_tracking_code_visits"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_tracking_code_visit

    queries do
      get :get_marketing_tracking_code_visit, :read
      list :list_marketing_tracking_code_visits, :read
    end

    mutations do
      create :create_marketing_tracking_code_visit, :create
      update :update_marketing_tracking_code_visit, :update
      destroy :delete_marketing_tracking_code_visit, :destroy
    end

  end

  attributes do
    attribute :visit_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :source_enum_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :tracking_code, UniboExPoc.Ofbiz.Marketing.TrackingCode do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
