defmodule UniboExPoc.Ofbiz.Party.TermType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_term_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_term_type

    queries do
      get :get_party_term_type, :read
      list :list_party_term_types, :read
    end

    mutations do
      create :create_party_term_type, :create
      update :update_party_term_type, :update
      destroy :delete_party_term_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :term_type_id, :string do
      public? true
      description "条款类型编号"
    end
    attribute :has_table, :boolean do
      public? true
      description "有表"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_term_type, UniboExPoc.Ofbiz.Party.TermType do
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
