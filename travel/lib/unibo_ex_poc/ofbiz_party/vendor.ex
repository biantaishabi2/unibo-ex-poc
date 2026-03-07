defmodule UniboExPoc.Ofbiz.Party.Vendor do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_vendors"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_vendor

    queries do
      get :get_party_vendor, :read
      list :list_party_vendors, :read
    end

    mutations do
      create :create_party_vendor, :create
      update :update_party_vendor, :update
      destroy :delete_party_vendor, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :manifest_company_name, :string do
      public? true
      description "公司名称"
    end
    attribute :manifest_company_title, :string do
      public? true
      description "公司标题"
    end
    attribute :manifest_logo_url, :string do
      public? true
      description "标志URL"
    end
    attribute :manifest_policies, :string do
      public? true
      description "政策"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
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
