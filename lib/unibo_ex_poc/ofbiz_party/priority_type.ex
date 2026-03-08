defmodule UniboV4.Ofbiz.Party.PriorityType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_priority_types"
    repo UniboV4.Repo
  end

  graphql do
    type :party_priority_type

    queries do
      get :get_party_priority_type, :read
      list :list_party_priority_types, :read
    end

    mutations do
      create :create_party_priority_type, :create
      update :update_party_priority_type, :update
      destroy :delete_party_priority_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :priority_type_id, :string do
      public? true
      description "优先级类型编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
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
