defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_work_efforts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort

    queries do
      get :get_work_effort_work_effort, :read
      list :list_work_effort_work_efforts, :read
    end

    mutations do
      create :create_work_effort_work_effort, :create
      update :update_work_effort_work_effort, :update
      destroy :delete_work_effort_work_effort, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :work_effort_id, :string, public?: true
    attribute :last_status_update, :utc_datetime, public?: true
    attribute :priority, :integer, public?: true
    attribute :percent_complete, :integer, public?: true
    attribute :work_effort_name, :string, public?: true
    attribute :show_as_enum_id, :string, public?: true
    attribute :send_notification_email, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :location_desc, :string, public?: true
    attribute :estimated_start_date, :utc_datetime, public?: true
    attribute :estimated_completion_date, :utc_datetime, public?: true
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_completion_date, :utc_datetime, public?: true
    attribute :estimated_milli_seconds, :float, public?: true
    attribute :estimated_setup_millis, :float, public?: true
    attribute :actual_milli_seconds, :float, public?: true
    attribute :actual_setup_millis, :float, public?: true
    attribute :total_milli_seconds_allowed, :float, public?: true
    attribute :total_money_allowed, :decimal, public?: true
    attribute :special_terms, :string, public?: true
    attribute :time_transparency, :integer do
      public? true
      description "已弃用 - 改用分配实体中的 availabilityStatusId 字段"
    end
    attribute :universal_id, :string, public?: true
    attribute :source_reference_id, :string, public?: true
    attribute :info_url, :string, public?: true
    attribute :service_loader_name, :string, public?: true
    attribute :quantity_to_produce, :decimal, public?: true
    attribute :quantity_produced, :decimal, public?: true
    attribute :quantity_rejected, :decimal, public?: true
    attribute :reserv_persons, :decimal do
      public? true
      description "租赁关联资产的人数"
    end
    attribute :reserv2nd_pp_perc, :decimal do
      public? true
      description "预订第二人价格百分比：与工作任务关联的此资产第二个租赁人的最终价格百分比"
    end
    attribute :reserv_nth_pp_perc, :decimal do
      public? true
      description "预订第N人价格百分比：与工作任务关联的此资产第N个（2+）租赁人的最终价格百分比"
    end
    attribute :revision_number, :integer, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort_type, UniboExPoc.Ofbiz.WorkEffort.WorkEffortType do
      public? true
      attribute_type :string
    end
    belongs_to :work_effort_purpose_type, UniboExPoc.Ofbiz.WorkEffort.WorkEffortPurposeType do
      public? true
      attribute_type :string
    end
    belongs_to :parent_work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      source_attribute :work_effort_parent_id
      attribute_type :string
    end
    belongs_to :current_status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :current_status_id
      attribute_type :string
    end
    belongs_to :scope_enumeration, UniboExPoc.Ofbiz.WorkEffort.Enumeration do
      public? true
      source_attribute :scope_enum_id
      attribute_type :string
    end
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.WorkEffort.FixedAsset do
      public? true
      attribute_type :string
    end
    belongs_to :facility, UniboExPoc.Ofbiz.WorkEffort.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :money_uom, UniboExPoc.Ofbiz.WorkEffort.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :recurrence_info, UniboExPoc.Ofbiz.WorkEffort.RecurrenceInfo do
      public? true
      attribute_type :string
    end
    belongs_to :temporal_expression, UniboExPoc.Ofbiz.WorkEffort.TemporalExpression do
      public? true
      source_attribute :temp_expr_id
      attribute_type :string
    end
    belongs_to :runtime_data, UniboExPoc.Ofbiz.WorkEffort.RuntimeData do
      public? true
      attribute_type :string
    end
    belongs_to :note_data, UniboExPoc.Ofbiz.WorkEffort.NoteData do
      public? true
      source_attribute :note_id
      attribute_type :string
    end
    belongs_to :custom_method, UniboExPoc.Ofbiz.WorkEffort.CustomMethod do
      public? true
      source_attribute :estimate_calc_method
      attribute_type :string
    end
    belongs_to :accommodation_map, UniboExPoc.Ofbiz.WorkEffort.AccommodationMap do
      public? true
      attribute_type :string
    end
    belongs_to :accommodation_spot, UniboExPoc.Ofbiz.WorkEffort.AccommodationSpot do
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
