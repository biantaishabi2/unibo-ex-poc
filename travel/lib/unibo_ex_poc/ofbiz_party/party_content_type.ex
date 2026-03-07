defmodule UniboExPoc.Ofbiz.Party.PartyContentType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_content_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_content_type

    queries do
      get :get_party_party_content_type, :read
      list :list_party_party_content_types, :read
    end

    mutations do
      create :create_party_party_content_type, :create
      update :update_party_party_content_type, :update
      destroy :delete_party_party_content_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_content_type_id, :string do
      public? true
      description "参与方内容类型编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_party_content_type, UniboExPoc.Ofbiz.Party.PartyContentType do
      public? true
      source_attribute :parent_type_id
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
