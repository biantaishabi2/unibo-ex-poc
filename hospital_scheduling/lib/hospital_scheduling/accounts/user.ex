defmodule HospitalScheduling.Accounts.User do
  @moduledoc """
  最小 User 资源，仅供 AshPaperTrail belongs_to_actor 引用。
  """
  use Ash.Resource,
    domain: HospitalScheduling.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo HospitalScheduling.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  actions do
    defaults [:read, :create]
  end
end
