defmodule UniboV4.Ofbiz.Party.Affiliate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_affiliates"
    repo UniboV4.Repo
  end

  graphql do
    type :party_affiliate

    queries do
      get :get_party_affiliate, :read
      list :list_party_affiliates, :read
    end

    mutations do
      create :create_party_affiliate, :create
      update :update_party_affiliate, :update
      destroy :delete_party_affiliate, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :affiliate_name, :string do
      public? true
      description "联盟名称"
    end
    attribute :affiliate_description, :string do
      public? true
      description "联盟说明"
    end
    attribute :year_established, :string do
      public? true
      description "建立年份"
    end
    attribute :site_type, :string do
      public? true
      description "站点类型"
    end
    attribute :site_page_views, :string do
      public? true
      description "站点页面浏览"
    end
    attribute :site_visitors, :string do
      public? true
      description "站点访问者"
    end
    attribute :date_time_created, :utc_datetime do
      public? true
      description "日期时间创建"
    end
    attribute :date_time_approved, :utc_datetime do
      public? true
      description "日期时间已审批"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :party_group, UniboV4.Ofbiz.Party.PartyGroup do
      public? true
      source_attribute :party_id
      define_attribute? false
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
