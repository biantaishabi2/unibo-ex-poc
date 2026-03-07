defmodule UniboExPoc.Ofbiz.Common.UomConversion do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Unit Of Measure Conversion Type"
  end

  postgres do
    table "common_uom_conversions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_uom_conversion

    queries do
      get :get_common_uom_conversion, :read
      list :list_common_uom_conversions, :read
    end

    mutations do
      create :create_common_uom_conversion, :create
      update :update_common_uom_conversion, :update
      destroy :delete_common_uom_conversion, :destroy
    end

  end

  attributes do
    attribute :uom_id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :uom_id_to, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :conversion_factor, :float, public?: true
    attribute :decimal_scale, :integer, public?: true
    attribute :rounding_mode, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :main_uom, UniboExPoc.Ofbiz.Common.Uom do
      public? true
      source_attribute :uom_id
      define_attribute? false
    end
    belongs_to :conv_to_uom, UniboExPoc.Ofbiz.Common.Uom do
      public? true
      source_attribute :uom_id_to
      define_attribute? false
    end
    belongs_to :uom_custom_method_custom_method, UniboExPoc.Ofbiz.Common.CustomMethod do
      public? true
      source_attribute :custom_method_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
