defmodule UniboExPoc.Ofbiz.Party.PartyNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_notes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_note

    queries do
      get :get_party_party_note, :read
      list :list_party_party_notes, :read
    end

    mutations do
      create :create_party_party_note, :create
      update :update_party_party_note, :update
      destroy :delete_party_party_note, :destroy
    end

  end

  attributes do
    attribute :party_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方编号"
    end
    attribute :note_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "备注编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      define_attribute? false
    end
    belongs_to :note_data, UniboExPoc.Ofbiz.Party.NoteData do
      public? true
      source_attribute :note_id
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
