defmodule UniboExPoc.Ofbiz.Content.ContentApproval do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_approvals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content_approval

    queries do
      get :get_content_content_approval, :read
      list :list_content_content_approvals, :read
    end

    mutations do
      create :create_content_content_approval, :create
      update :update_content_content_approval, :update
      destroy :delete_content_content_approval, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :content_approval_id, :string, public?: true
    attribute :content_revision_seq_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :approval_status_id, :string, public?: true
    attribute :approval_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
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
