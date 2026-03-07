defmodule UniboExPoc.Ofbiz.Shipment.RejectionReason do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_rejection_reasons"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_rejection_reason

    queries do
      get :get_shipment_rejection_reason, :read
      list :list_shipment_rejection_reasons, :read
    end

    mutations do
      create :create_shipment_rejection_reason, :create
      update :update_shipment_rejection_reason, :update
      destroy :delete_shipment_rejection_reason, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :rejection_id, :string, public?: true
    attribute :description, :string, public?: true
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
