defmodule UniboV4.PLM.EcoTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "ECO-标签桥接占位实体"
  end

  postgres do
    table "plm_eco_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco_tag_link

    queries do
      get :get_plm_eco_tag_link, :read
      list :list_plm_eco_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :eco, UniboV4.PLM.Eco do
      public? true
      allow_nil? false
    end
    belongs_to :eco_tag, UniboV4.PLM.EcoTag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
