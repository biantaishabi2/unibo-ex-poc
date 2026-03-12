defmodule UniboExPoc.Ofbiz.Accounting.GlXbrlClass do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_xbrl_classes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_gl_xbrl_class

    queries do
      get :get_ofbiz_accounting_gl_xbrl_class, :read
      list :list_ofbiz_accounting_gl_xbrl_classs, :read
    end

    mutations do
      create :create_ofbiz_accounting_gl_xbrl_class, :create
      update :update_ofbiz_accounting_gl_xbrl_class, :update
      destroy :delete_ofbiz_accounting_gl_xbrl_class, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_xbrl_class_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_gl_xbrl_class, UniboExPoc.Ofbiz.Accounting.GlXbrlClass do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
