# Workflow: quality_reason_maintain_flow — 根本原因维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Quality.QualityReason do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "根本原因字典，用于 QualityAlert 根因分类"
  end

  postgres do
    table "quality_reasons"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_reason

    queries do
      get :get_quality_quality_reason, :read
      list :list_quality_quality_reasons, :read
    end

    mutations do
      create :create_quality_quality_reason, :create
      update :update_quality_quality_reason, :update
      destroy :delete_quality_quality_reason, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "原因名称"
    end
    attribute :description, :string do
      public? true
      description "原因说明"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :alerts, UniboExPoc.Quality.QualityAlert do
      public? true
      destination_attribute :root_cause_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_reason_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:alerts]
  end

end
