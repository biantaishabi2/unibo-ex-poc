defmodule UniboV4.Ofbiz.Content.CharacterSet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_character_sets"
    repo UniboV4.Repo
  end

  graphql do
    type :content_character_set

    queries do
      get :get_content_character_set, :read
      list :list_content_character_sets, :read
    end

    mutations do
      create :create_content_character_set, :create
      update :update_content_character_set, :update
      destroy :delete_content_character_set, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :character_set_id, :string, public?: true
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
