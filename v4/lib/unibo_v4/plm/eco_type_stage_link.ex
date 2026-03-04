defmodule UniboV4.PLM.EcoTypeStageLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "plm_eco_type_stage_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :eco_type, UniboV4.PLM.EcoType do
      public? true
      allow_nil? false
    end
    belongs_to :eco_stage, UniboV4.PLM.EcoStage do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
