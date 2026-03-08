defmodule UniboExPoc.Ofbiz.Common.UomConversionDated do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Unit Of Measure Conversion Entity for those Units of Measure whose conversion values change over time (ie, currencies)"
  end

  postgres do
    table "common_uom_conversion_dateds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_uom_conversion_dated

    queries do
      get :get_common_uom_conversion_dated, :read
      list :list_common_uom_conversion_dateds, :read
    end

    mutations do
      create :create_common_uom_conversion_dated, :create
      update :update_common_uom_conversion_dated, :update
      destroy :delete_common_uom_conversion_dated, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :conversion_factor, :float, public?: true
    attribute :decimal_scale, :integer, public?: true
    attribute :rounding_mode, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :dated_main_uom, UniboExPoc.Ofbiz.Common.Uom do
      public? true
      source_attribute :uom_id
    end
    belongs_to :dated_conv_to_uom, UniboExPoc.Ofbiz.Common.Uom do
      public? true
      source_attribute :uom_id_to
    end
    belongs_to :uom_custom_method_custom_method, UniboExPoc.Ofbiz.Common.CustomMethod do
      public? true
      source_attribute :custom_method_id
    end
    belongs_to :purpose_enumeration, UniboExPoc.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :purpose_enum_id
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
