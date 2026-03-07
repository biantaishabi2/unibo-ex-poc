defmodule UniboExPoc.Ofbiz.Content.ContentSearchConstraint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_search_constraints"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_search_constraint

    queries do
      get :get_content_content_search_constraint, :read
      list :list_content_content_search_constraints, :read
    end

    mutations do
      create :create_content_content_search_constraint, :create
      update :update_content_content_search_constraint, :update
      destroy :delete_content_content_search_constraint, :destroy
    end

  end

  attributes do
    attribute :constraint_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :constraint_name, :string, public?: true
    attribute :info_string, :string, public?: true
    attribute :include_sub_categories, :boolean, public?: true
    attribute :is_and, :boolean, public?: true
    attribute :any_prefix, :boolean, public?: true
    attribute :any_suffix, :boolean, public?: true
    attribute :remove_stems, :boolean, public?: true
    attribute :low_value, :string, public?: true
    attribute :high_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content_search_result, UniboExPoc.Ofbiz.Content.ContentSearchResult do
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
