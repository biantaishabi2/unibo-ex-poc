defmodule UniboV4.PLM.EcoTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "plm_eco_tag_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
