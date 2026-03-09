defmodule UniboExPoc.PLM.MrpBom do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "BOM占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "plm_mrp_boms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_mrp_bom

    queries do
      get :get_plm_mrp_bom, :read
      list :list_plm_mrp_boms, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :active, :boolean, public?: true
    attribute :version, :integer, public?: true
    attribute :bom_line_ids, {:array, :string} do
      public? true
      description "BOM 明细行引用集合（供 ECO 差异计算）"
    end
  end

  actions do
    defaults [:read, :update]
  end

end
