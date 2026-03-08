defmodule UniboV4.Ofbiz.Accounting.AccommodationClass do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_accommodation_classes"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_accommodation_class

    queries do
      get :get_accounting_accommodation_class, :read
      list :list_accounting_accommodation_classs, :read
    end

    mutations do
      create :create_accounting_accommodation_class, :create
      update :update_accounting_accommodation_class, :update
      destroy :delete_accounting_accommodation_class, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :accommodation_class_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_accommodation_class, UniboV4.Ofbiz.Accounting.AccommodationClass do
      public? true
      source_attribute :parent_class_id
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
