defmodule UniboExPoc.Ofbiz.Content.ContentOperation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_operations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_operation

    queries do
      get :get_content_content_operation, :read
      list :list_content_content_operations, :read
    end

    mutations do
      create :create_content_content_operation, :create
      update :update_content_content_operation, :update
      destroy :delete_content_content_operation, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :content_operation_id, :string, public?: true
    attribute :description, :string, public?: true
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
