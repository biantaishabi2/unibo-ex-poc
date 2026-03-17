defmodule UniboExPoc.Ofbiz.Accounting.GlAccountClass do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_classes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_gl_account_class

    queries do
      get :get_ofbiz_accounting_gl_account_class, :read
      list :list_ofbiz_accounting_gl_account_classs, :read
    end

    mutations do
      create :create_ofbiz_accounting_gl_account_class, :create
      update :update_ofbiz_accounting_gl_account_class, :update
      destroy :delete_ofbiz_accounting_gl_account_class, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_account_class_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :is_asset_class, :boolean, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_gl_account_class, UniboExPoc.Ofbiz.Accounting.GlAccountClass do
      public? true
      source_attribute :parent_class_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
