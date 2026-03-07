defmodule UniboExPoc.Ofbiz.Party.NeedType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_need_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_need_type

    queries do
      get :get_party_need_type, :read
      list :list_party_need_types, :read
    end

    mutations do
      create :create_party_need_type, :create
      update :update_party_need_type, :update
      destroy :delete_party_need_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :need_type_id, :string do
      public? true
      description "需求类型编号"
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
