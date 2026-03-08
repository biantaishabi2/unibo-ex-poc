defmodule UniboV4.Ofbiz.Content.DataCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_data_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :content_data_category

    queries do
      get :get_content_data_category, :read
      list :list_content_data_categorys, :read
    end

    mutations do
      create :create_content_data_category, :create
      update :update_content_data_category, :update
      destroy :delete_content_data_category, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :data_category_id, :string, public?: true
    attribute :category_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_data_category, UniboV4.Ofbiz.Content.DataCategory do
      public? true
      source_attribute :parent_category_id
      attribute_type :string
    end
    has_many :sibling_data_category, UniboV4.Ofbiz.Content.DataCategory do
      public? true
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
    archive_related [:sibling_data_category]
  end

end
