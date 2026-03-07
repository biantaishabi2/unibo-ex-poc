defmodule UniboExPoc.Ofbiz.Content.ContentKeyword do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_keywords"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_keyword

    queries do
      get :get_content_content_keyword, :read
      list :list_content_content_keywords, :read
    end

    mutations do
      create :create_content_content_keyword, :create
      update :update_content_content_keyword, :update
      destroy :delete_content_content_keyword, :destroy
    end

  end

  attributes do
    attribute :keyword, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :relevancy_weight, :integer, public?: true
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
