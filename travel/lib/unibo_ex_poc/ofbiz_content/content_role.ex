defmodule UniboExPoc.Ofbiz.Content.ContentRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_role

    queries do
      get :get_content_content_role, :read
      list :list_content_content_roles, :read
    end

    mutations do
      create :create_content_content_role, :create
      update :update_content_content_role, :update
      destroy :delete_content_content_role, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
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
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
