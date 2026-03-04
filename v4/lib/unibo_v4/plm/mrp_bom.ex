defmodule UniboV4.PLM.MrpBom do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "plm_mrp_boms"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :active, :boolean, public?: true
    attribute :version, :integer, public?: true
    attribute :bom_line_ids, {:array, :string}, public?: true
  end

  actions do
    defaults [:read]
  end

end
