defmodule UniboExPoc.PLM.EcoTypeStageLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "ECO类型-阶段桥接占位实体"
  end

  postgres do
    table "plm_eco_type_stage_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_eco_type_stage_link

    queries do
      get :get_plm_eco_type_stage_link, :read
      list :list_plm_eco_type_stage_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :eco_type, UniboExPoc.PLM.EcoType do
      public? true
      allow_nil? false
    end
    belongs_to :eco_stage, UniboExPoc.PLM.EcoStage do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
