defmodule UniboExPoc.Ofbiz.Content.ContentSearchResult do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_search_results"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_search_result

    queries do
      get :get_content_content_search_result, :read
      list :list_content_content_search_results, :read
    end

    mutations do
      create :create_content_content_search_result, :create
      update :update_content_content_search_result, :update
      destroy :delete_content_content_search_result, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :content_search_result_id, :string, public?: true
    attribute :visit_id, :string, public?: true
    attribute :order_by_name, :string, public?: true
    attribute :is_ascending, :boolean, public?: true
    attribute :num_results, :integer, public?: true
    attribute :seconds_total, :float, public?: true
    attribute :search_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
