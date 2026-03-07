defmodule UniboExPoc.Ofbiz.Common.KeywordThesaurus do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "common_keyword_thesauruss"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_keyword_thesaurus

    queries do
      get :get_common_keyword_thesaurus, :read
      list :list_common_keyword_thesauruss, :read
    end

    mutations do
      create :create_common_keyword_thesaurus, :create
      update :update_common_keyword_thesaurus, :update
      destroy :delete_common_keyword_thesaurus, :destroy
    end

  end

  attributes do
    attribute :entered_keyword, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :alternate_keyword, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :relationship_enumeration, UniboExPoc.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :relationship_enum_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
