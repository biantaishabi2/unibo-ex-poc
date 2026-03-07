defmodule UniboExPoc.Ofbiz.Party.AgreementStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_status

    queries do
      get :get_party_agreement_status, :read
      list :list_party_agreement_statuss, :read
    end

    mutations do
      create :create_party_agreement_status, :create
      update :update_party_agreement_status, :update
      destroy :delete_party_agreement_status, :destroy
    end

  end

  attributes do
    attribute :status_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
      description "状态日期"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Party.StatusItem do
      public? true
      source_attribute :status_id
    end
    belongs_to :change_by_user_login, UniboExPoc.Ofbiz.Party.UserLogin do
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
