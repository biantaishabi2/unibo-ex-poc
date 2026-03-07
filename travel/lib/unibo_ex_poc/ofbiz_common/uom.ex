defmodule UniboExPoc.Ofbiz.Common.Uom do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Unit Of Measure"
  end

  postgres do
    table "common_uoms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_uom

    queries do
      get :get_common_uom, :read
      list :list_common_uoms, :read
    end

    mutations do
      create :create_common_uom, :create
      update :update_common_uom, :update
      destroy :delete_common_uom, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :uom_id, :string, public?: true
    attribute :abbreviation, :string, public?: true
    attribute :numeric_code, :integer, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :uom_type, UniboExPoc.Ofbiz.Common.UomType do
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
