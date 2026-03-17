defmodule UniboExPoc.Ofbiz.Party.PartyGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_party_party_group

    queries do
      get :get_ofbiz_party_party_group, :read
      list :list_ofbiz_party_party_groups, :read
    end

    mutations do
      create :create_ofbiz_party_party_group, :create
      update :update_ofbiz_party_party_group, :update
      destroy :delete_ofbiz_party_party_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :group_name, :string do
      public? true
      description "分组名称"
    end
    attribute :group_name_local, :string do
      public? true
      description "本地分组名称"
    end
    attribute :office_site_name, :string do
      public? true
      description "办公室站点名称"
    end
    attribute :annual_revenue, :decimal do
      public? true
      description "年收入"
    end
    attribute :num_employees, :integer do
      public? true
      description "员工数量"
    end
    attribute :ticker_symbol, :string do
      public? true
      description "股票代码"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :logo_image_url, :string do
      public? true
      description "标识图片链接"
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

  archive do
  end

end
