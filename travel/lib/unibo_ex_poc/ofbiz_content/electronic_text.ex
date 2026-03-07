defmodule UniboExPoc.Ofbiz.Content.ElectronicText do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_electronic_texts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_electronic_text

    queries do
      get :get_content_electronic_text, :read
      list :list_content_electronic_texts, :read
    end

    mutations do
      create :create_content_electronic_text, :create
      update :update_content_electronic_text, :update
      destroy :delete_content_electronic_text, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :text_data, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource, UniboExPoc.Ofbiz.Content.DataResource do
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
