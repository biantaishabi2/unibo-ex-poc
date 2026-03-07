defmodule UniboExPoc.Ofbiz.Content.ContentAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_assoc

    queries do
      get :get_content_content_assoc, :read
      list :list_content_content_assocs, :read
    end

    mutations do
      create :create_content_content_assoc, :create
      update :update_content_content_assoc, :update
      destroy :delete_content_content_assoc, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :data_source_id, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :map_key, :string, public?: true
    attribute :upper_coordinate, :integer, public?: true
    attribute :left_coordinate, :integer, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      source_attribute :content_id
      attribute_type :string
    end
    belongs_to :to_content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      source_attribute :content_id_to
      attribute_type :string
    end
    belongs_to :content_assoc_type, UniboExPoc.Ofbiz.Content.ContentAssocType do
      public? true
      attribute_type :string
    end
    belongs_to :content_assoc_predicate, UniboExPoc.Ofbiz.Content.ContentAssocPredicate do
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
