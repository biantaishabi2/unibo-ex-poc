defmodule UniboExPoc.Quality.QualityProfile do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "质检员的业务扩展属性，通过 Party 关联"
  end

  postgres do
    table "quality_profiles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_profile

    queries do
      get :get_quality_quality_profile, :read
      list :list_quality_quality_profiles, :read
    end

    mutations do
      create :create_quality_quality_profile, :create
      update :update_quality_quality_profile, :update
      destroy :delete_quality_quality_profile, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :certification_level, :atom do
      constraints one_of: [:basic, :intermediate, :advanced, :expert]
      public? true
      description "质检员资质等级"
    end
    attribute :specialization, :string do
      public? true
      description "专业方向"
    end
    attribute :inspection_count, :integer do
      default 0
      public? true
      description "累计检查次数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Quality.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:certification_level, :specialization]
      argument :party_id, :uuid, allow_nil?: false
      change manage_relationship(:party_id, :party, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:certification_level, :specialization, :inspection_count]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
