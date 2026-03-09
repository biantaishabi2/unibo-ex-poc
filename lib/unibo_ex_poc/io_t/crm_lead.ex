defmodule UniboExPoc.IoT.CrmLead do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "商机占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "io_t_crm_leads"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_crm_lead

    queries do
      get :get_io_t_crm_lead, :read
      list :list_io_t_crm_leads, :read
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
