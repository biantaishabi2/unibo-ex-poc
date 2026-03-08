defmodule UniboV4.Ofbiz.WorkEffort.TimeEntry do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_time_entries"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_time_entry

    queries do
      get :get_work_effort_time_entry, :read
      list :list_work_effort_time_entrys, :read
    end

    mutations do
      create :create_work_effort_time_entry, :create
      update :update_work_effort_time_entry, :update
      destroy :delete_work_effort_time_entry, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :time_entry_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :invoice_item_seq_id, :string, public?: true
    attribute :hours, :float, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.WorkEffort.Party do
      public? true
      attribute_type :string
    end
    belongs_to :rate_type, UniboV4.Ofbiz.WorkEffort.RateType do
      public? true
      attribute_type :string
    end
    belongs_to :work_effort, UniboV4.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :timesheet, UniboV4.Ofbiz.WorkEffort.Timesheet do
      public? true
      attribute_type :string
    end
    belongs_to :invoice, UniboV4.Ofbiz.WorkEffort.Invoice do
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
