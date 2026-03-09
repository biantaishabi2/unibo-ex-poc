defmodule UniboExPoc.Ofbiz.Shipment.OldPicklistStatusHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "已弃用：自分支发布后弃用。请改用 PicklistStatus"
  end

  postgres do
    table "shipment_old_picklist_status_histories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_old_picklist_status_history

    queries do
      get :get_shipment_old_picklist_status_history, :read
      list :list_shipment_old_picklist_status_historys, :read
    end

    mutations do
      create :create_shipment_old_picklist_status_history, :create
      update :update_shipment_old_picklist_status_history, :update
      destroy :delete_shipment_old_picklist_status_history, :destroy
    end

  end

  attributes do
    attribute :change_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :picklist, UniboExPoc.Ofbiz.Shipment.Picklist do
      public? true
      attribute_type :string
    end
    belongs_to :change_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :to_status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id_to
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
