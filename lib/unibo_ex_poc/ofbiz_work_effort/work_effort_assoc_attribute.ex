defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortAssocAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_assoc_attributes"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_assoc_attribute

    queries do
      get :get_work_effort_work_effort_assoc_attribute, :read
      list :list_work_effort_work_effort_assoc_attributes, :read
    end

    mutations do
      create :create_work_effort_work_effort_assoc_attribute, :create
      update :update_work_effort_work_effort_assoc_attribute, :update
      destroy :delete_work_effort_work_effort_assoc_attribute, :destroy
    end

  end

  attributes do
    attribute :work_effort_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :work_effort_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :work_effort_assoc_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime, public?: true
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
