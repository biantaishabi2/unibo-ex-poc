defmodule UniboExPoc.Ofbiz.Service.TemporalExpression do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Temporal Expression"
  end

  postgres do
    table "service_temporal_expressions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :service_temporal_expression

    queries do
      get :get_service_temporal_expression, :read
      list :list_service_temporal_expressions, :read
    end

    mutations do
      create :create_service_temporal_expression, :create
      update :update_service_temporal_expression, :update
      destroy :delete_service_temporal_expression, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :temp_expr_id, :string, public?: true
    attribute :temp_expr_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :date1, :utc_datetime, public?: true
    attribute :date2, :utc_datetime, public?: true
    attribute :integer1, :integer, public?: true
    attribute :integer2, :integer, public?: true
    attribute :string1, :string, public?: true
    attribute :string2, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
