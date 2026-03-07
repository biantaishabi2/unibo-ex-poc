defmodule UniboExPoc.Ofbiz.Party.PartyClassificationGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_classification_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_classification_group

    queries do
      get :get_party_party_classification_group, :read
      list :list_party_party_classification_groups, :read
    end

    mutations do
      create :create_party_party_classification_group, :create
      update :update_party_party_classification_group, :update
      destroy :delete_party_party_classification_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_classification_group_id, :string do
      public? true
      description "参与方分类组编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_party_classification_group, UniboExPoc.Ofbiz.Party.PartyClassificationGroup do
      public? true
      source_attribute :parent_group_id
    end
    belongs_to :party_classification_type, UniboExPoc.Ofbiz.Party.PartyClassificationType do
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
