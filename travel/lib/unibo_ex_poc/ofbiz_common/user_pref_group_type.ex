defmodule UniboExPoc.Ofbiz.Common.UserPrefGroupType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "The UserPrefGroupType entity contains one entry per preference
          group type."
  end

  postgres do
    table "common_user_pref_group_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_user_pref_group_type

    queries do
      get :get_common_user_pref_group_type, :read
      list :list_common_user_pref_group_types, :read
    end

    mutations do
      create :create_common_user_pref_group_type, :create
      update :update_common_user_pref_group_type, :update
      destroy :delete_common_user_pref_group_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :user_pref_group_type_id, :string, public?: true
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
