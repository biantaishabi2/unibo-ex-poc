defmodule UniboExPoc.Ofbiz.Common.StatusItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Status"
  end

  postgres do
    table "common_status_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_status_item

    queries do
      get :get_common_status_item, :read
      list :list_common_status_items, :read
    end

    mutations do
      create :create_common_status_item, :create
      update :update_common_status_item, :update
      destroy :delete_common_status_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status_id, :string, public?: true
    attribute :status_code, :string, public?: true
    attribute :sequence_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :status_type, UniboExPoc.Ofbiz.Common.StatusType do
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
