defmodule UniboExPoc.Ofbiz.Common.StandardLanguage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "common_standard_languages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_standard_language

    queries do
      get :get_common_standard_language, :read
      list :list_common_standard_languages, :read
    end

    mutations do
      create :create_common_standard_language, :create
      update :update_common_standard_language, :update
      destroy :delete_common_standard_language, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :standard_language_id, :string, public?: true
    attribute :lang_code3t, :string, public?: true
    attribute :lang_code3b, :string, public?: true
    attribute :lang_code2, :string, public?: true
    attribute :lang_name, :string, public?: true
    attribute :lang_family, :string, public?: true
    attribute :lang_charset, :string, public?: true
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
