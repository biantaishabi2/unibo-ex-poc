defmodule UniboExPoc.Ofbiz.Content.ContentPurposeOperation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_purpose_operations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_purpose_operation

    queries do
      get :get_content_content_purpose_operation, :read
      list :list_content_content_purpose_operations, :read
    end

    mutations do
      create :create_content_content_purpose_operation, :create
      update :update_content_content_purpose_operation, :update
      destroy :delete_content_content_purpose_operation, :destroy
    end

  end

  attributes do
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :privilege_enum_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content_purpose_type, UniboExPoc.Ofbiz.Content.ContentPurposeType do
      public? true
      attribute_type :string
    end
    belongs_to :content_operation, UniboExPoc.Ofbiz.Content.ContentOperation do
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
