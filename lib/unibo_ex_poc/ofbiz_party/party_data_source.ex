defmodule UniboExPoc.Ofbiz.Party.PartyDataSource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_party_data_sources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_data_source

    queries do
      get :get_party_party_data_source, :read
      list :list_party_party_data_sources, :read
    end

    mutations do
      create :create_party_party_data_source, :create
      update :update_party_party_data_source, :update
      destroy :delete_party_party_data_source, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "来源日期"
    end
    attribute :visit_id, :string do
      public? true
      description "访问编号"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :is_create, :boolean do
      public? true
      description "是创建"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
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
  end

end
