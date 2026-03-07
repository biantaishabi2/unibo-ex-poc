defmodule UniboExPoc.Ofbiz.Party.AgreementRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_role

    queries do
      get :get_party_agreement_role, :read
      list :list_party_agreement_roles, :read
    end

    mutations do
      create :create_party_agreement_role, :create
      update :update_party_agreement_role, :update
      destroy :delete_party_agreement_role, :destroy
    end

  end

  attributes do
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
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
