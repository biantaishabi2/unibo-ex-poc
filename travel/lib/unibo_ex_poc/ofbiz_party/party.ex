defmodule UniboExPoc.Ofbiz.Party.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party

    queries do
      get :get_party_party, :read
      list :list_party_partys, :read
    end

    mutations do
      create :create_party_party, :create
      update :update_party_party, :update
      destroy :delete_party_party, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_id, :string do
      public? true
      description "参与方编号"
    end
    attribute :external_id, :string do
      public? true
      description "外部编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :created_date, :utc_datetime do
      public? true
      description "创建日期"
    end
    attribute :last_modified_date, :utc_datetime do
      public? true
      description "最近修改日期"
    end
    attribute :is_unread, :boolean do
      public? true
      description "未读"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party_type, UniboExPoc.Ofbiz.Party.PartyType do
      public? true
    end
    belongs_to :created_by_user_login_rel, UniboExPoc.Ofbiz.Party.UserLogin do
      public? true
      source_attribute :created_by_user_login
    end
    belongs_to :last_modified_by_user_login_rel, UniboExPoc.Ofbiz.Party.UserLogin do
      public? true
      source_attribute :last_modified_by_user_login
    end
    belongs_to :uom, UniboExPoc.Ofbiz.Party.Uom do
      public? true
      source_attribute :preferred_currency_uom_id
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Party.StatusItem do
      public? true
      source_attribute :status_id
    end
    has_many :party_type_attr, UniboExPoc.Ofbiz.Party.PartyTypeAttr do
      public? true
      source_attribute :party_type_id
      destination_attribute :party_type_id
    end
    belongs_to :data_source, UniboExPoc.Ofbiz.Party.DataSource do
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
    archive_related [:party_type_attr]
  end

end
