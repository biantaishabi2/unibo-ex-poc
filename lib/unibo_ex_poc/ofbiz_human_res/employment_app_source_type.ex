defmodule UniboV4.Ofbiz.HumanRes.EmploymentAppSourceType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_employment_app_source_types"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_employment_app_source_type

    queries do
      get :get_human_res_employment_app_source_type, :read
      list :list_human_res_employment_app_source_types, :read
    end

    mutations do
      create :create_human_res_employment_app_source_type, :create
      update :update_human_res_employment_app_source_type, :update
      destroy :delete_human_res_employment_app_source_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :employment_app_source_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_employment_app_source_type, UniboV4.Ofbiz.HumanRes.EmploymentAppSourceType do
      public? true
      source_attribute :parent_type_id
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
