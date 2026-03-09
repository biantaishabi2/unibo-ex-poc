defmodule UniboExPoc.Ofbiz.HumanRes.Payment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer

  resource do
    description "占位实体（Batch B2 关系补全）"
  end

  postgres do
    table "human_res_payments"
    repo UniboExPoc.Repo
  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
  end

end
