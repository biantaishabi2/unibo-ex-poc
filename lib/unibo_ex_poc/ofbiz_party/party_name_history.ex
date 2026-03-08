defmodule UniboV4.Ofbiz.Party.PartyNameHistory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_name_histories"
    repo UniboV4.Repo
  end

  graphql do
    type :party_party_name_history

    queries do
      get :get_party_party_name_history, :read
      list :list_party_party_name_historys, :read
    end

    mutations do
      create :create_party_party_name_history, :create
      update :update_party_party_name_history, :update
      destroy :delete_party_party_name_history, :destroy
    end

  end

  attributes do
    attribute :change_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "变更日期"
    end
    attribute :group_name, :string do
      public? true
      description "仅用于参与方组（团体名称）"
    end
    attribute :first_name, :string do
      public? true
      description "名"
    end
    attribute :middle_name, :string do
      public? true
      description "中间名"
    end
    attribute :last_name, :string do
      public? true
      description "姓"
    end
    attribute :personal_title, :string do
      public? true
      description "个人称谓"
    end
    attribute :suffix, :string do
      public? true
      description "后缀"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
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
  end

end
