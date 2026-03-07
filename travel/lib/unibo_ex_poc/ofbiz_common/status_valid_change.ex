defmodule UniboExPoc.Ofbiz.Common.StatusValidChange do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Status Valid Change"
  end

  postgres do
    table "common_status_valid_changes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_status_valid_change

    queries do
      get :get_common_status_valid_change, :read
      list :list_common_status_valid_changes, :read
    end

    mutations do
      create :create_common_status_valid_change, :create
      update :update_common_status_valid_change, :update
      destroy :delete_common_status_valid_change, :destroy
    end

  end

  attributes do
    attribute :condition_expression, :string, public?: true
    attribute :transition_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :main_status_item, UniboExPoc.Ofbiz.Common.StatusItem do
      public? true
      source_attribute :status_id
    end
    belongs_to :to_status_item, UniboExPoc.Ofbiz.Common.StatusItem do
      public? true
      source_attribute :status_id_to
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
