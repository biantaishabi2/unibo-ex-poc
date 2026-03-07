defmodule UniboExPoc.Ofbiz.Common.UserPreference do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "The UserPreference entity contains one entry per preference per
          userLogin. User preferences are stored as key/value pairs (userPrefTypeId/userPrefValue).
          All values are stored as strings. Value strings can be converted to
          other data types by specifying a java data type in the userPrefDataType field."
  end

  postgres do
    table "common_user_preferences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_user_preference

    queries do
      get :get_common_user_preference, :read
      list :list_common_user_preferences, :read
    end

    mutations do
      create :create_common_user_preference, :create
      update :update_common_user_preference, :update
      destroy :delete_common_user_preference, :destroy
    end

  end

  attributes do
    attribute :user_login_id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :user_pref_type_id, :string do
      primary_key? true
      allow_nil? false
      public? true
      description "A unique identifier for this preference"
    end
    attribute :user_pref_value, :string do
      public? true
      description "Contains the value of this preference"
    end
    attribute :user_pref_data_type, :string do
      public? true
      description "The java data type of this preference (empty = java.lang.String)"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :user_pref_group_type, UniboExPoc.Ofbiz.Common.UserPrefGroupType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
