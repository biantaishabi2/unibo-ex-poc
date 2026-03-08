defmodule UniboV4.Ofbiz.Content.WebSiteContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_web_site_contents"
    repo UniboV4.Repo
  end

  graphql do
    type :content_web_site_content

    queries do
      get :get_content_web_site_content, :read
      list :list_content_web_site_contents, :read
    end

    mutations do
      create :create_content_web_site_content, :create
      update :update_content_web_site_content, :update
      destroy :delete_content_web_site_content, :destroy
    end

  end

  attributes do
    attribute :web_site_id, :string do
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content, UniboV4.Ofbiz.Content.Content do
      public? true
      attribute_type :string
    end
    belongs_to :web_site_content_type, UniboV4.Ofbiz.Content.WebSiteContentType do
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
