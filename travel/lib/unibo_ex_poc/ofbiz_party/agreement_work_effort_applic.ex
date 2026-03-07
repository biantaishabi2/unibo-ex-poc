defmodule UniboExPoc.Ofbiz.Party.AgreementWorkEffortApplic do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_work_effort_applics"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_work_effort_applic

    queries do
      get :get_party_agreement_work_effort_applic, :read
      list :list_party_agreement_work_effort_applics, :read
    end

    mutations do
      create :create_party_agreement_work_effort_applic, :create
      update :update_party_agreement_work_effort_applic, :update
      destroy :delete_party_agreement_work_effort_applic, :destroy
    end

  end

  attributes do
    attribute :agreement_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "协议编号"
    end
    attribute :agreement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项序列编号"
    end
    attribute :work_effort_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "工作任务编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
      define_attribute? false
    end
    belongs_to :work_effort, UniboExPoc.Ofbiz.Party.WorkEffort do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
