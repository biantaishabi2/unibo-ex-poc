defmodule UniboExPoc.Ofbiz.Content.WebSitePathAlias do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_web_site_path_aliases"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_web_site_path_alias

    queries do
      get :get_content_web_site_path_alias, :read
      list :list_content_web_site_path_aliass, :read
    end

    mutations do
      create :create_content_web_site_path_alias, :create
      update :update_content_web_site_path_alias, :update
      destroy :delete_content_web_site_path_alias, :destroy
    end

  end

  attributes do
    attribute :web_site_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :path_alias, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :alias_to, :string, public?: true
    attribute :map_key, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
