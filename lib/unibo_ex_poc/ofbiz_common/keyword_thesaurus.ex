defmodule UniboV4.Ofbiz.Common.KeywordThesaurus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "common_keyword_thesauruss"
    repo UniboV4.Repo
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
    uuid_primary_key :id
    attribute :entered_keyword, :string, public?: true
    attribute :alternate_keyword, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :relationship_enumeration, UniboV4.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :relationship_enum_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  identities do
    identity :unique_entered_alternate, [:entered_keyword, :alternate_keyword]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
