defmodule UniboExPoc.HR.EmployeeCategoryLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "员工标签关联（through 表）"
  end

  postgres do
    table "hr_employee_category_links"
    repo UniboExPoc.Repo
    identity_index_names unique_employee_category: "idx_hr_employee_category_links_unique_employee_category"
  end

  graphql do
    type :hr_employee_category_link

    queries do
      get :get_hr_employee_category_link, :read
      list :list_hr_employee_category_links, :read
    end

    mutations do
      create :create_hr_employee_category_link, :create
      destroy :delete_hr_employee_category_link, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboExPoc.HR.EmployeeCategory do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      description "Create Employee Category Link via Create. doc_url: graphql://contract/hr/create_hr_employee_category_link"
      primary? true
      accept []
      argument :employee_id, :uuid, allow_nil?: false
      argument :category_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
    end
  end

  identities do
    identity :unique_employee_category, [:employee_id, :category_id]
  end

  archive do
  end

end
