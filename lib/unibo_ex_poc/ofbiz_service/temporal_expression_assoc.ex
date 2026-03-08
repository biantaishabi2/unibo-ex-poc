defmodule UniboV4.Ofbiz.Service.TemporalExpressionAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Temporal Expression Association"
  end

  postgres do
    table "service_temporal_expression_assocs"
    repo UniboV4.Repo
  end

  graphql do
    type :service_temporal_expression_assoc

    queries do
      get :get_service_temporal_expression_assoc, :read
      list :list_service_temporal_expression_assocs, :read
    end

    mutations do
      create :create_service_temporal_expression_assoc, :create
      update :update_service_temporal_expression_assoc, :update
      destroy :delete_service_temporal_expression_assoc, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :expr_assoc_type, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_temporal_expression, UniboV4.Ofbiz.Service.TemporalExpression do
      public? true
      source_attribute :from_temp_expr_id
    end
    belongs_to :to_temporal_expression, UniboV4.Ofbiz.Service.TemporalExpression do
      public? true
      source_attribute :to_temp_expr_id
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
