defmodule UniboExPoc.Ofbiz.Product.FacilityCalendar do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_calendars"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_calendar

    queries do
      get :get_product_facility_calendar, :read
      list :list_product_facility_calendars, :read
    end

    mutations do
      create :create_product_facility_calendar, :create
      update :update_product_facility_calendar, :update
      destroy :delete_product_facility_calendar, :destroy
    end

  end

  attributes do
    attribute :calendar_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
    end
    belongs_to :facility_calendar_type, UniboExPoc.Ofbiz.Product.FacilityCalendarType do
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
