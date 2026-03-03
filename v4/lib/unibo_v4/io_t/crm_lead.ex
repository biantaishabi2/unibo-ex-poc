defmodule UniboV4.IoT.CrmLead do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "io_t_crm_leads"
    repo UniboV4.Repo
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
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
