defmodule UniboExPoc.Ofbiz.Product.ProductStoreSurveyAppl do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_survey_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_survey_appl

    queries do
      get :get_product_product_store_survey_appl, :read
      list :list_product_product_store_survey_appls, :read
    end

    mutations do
      create :create_product_product_store_survey_appl, :create
      update :update_product_product_store_survey_appl, :update
      destroy :delete_product_product_store_survey_appl, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_store_survey_id, :string, public?: true
    attribute :survey_appl_type_id, :string, public?: true
    attribute :group_name, :string, public?: true
    attribute :survey_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :survey_template, :string, public?: true
    attribute :result_template, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
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
