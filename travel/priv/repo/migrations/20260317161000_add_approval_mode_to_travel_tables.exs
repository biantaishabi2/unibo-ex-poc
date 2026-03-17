defmodule UniboExPoc.Repo.Migrations.AddApprovalModeToTravelTables do
  use Ecto.Migration

  def up do
    alter table(:travel_policies) do
      add :approval_mode, :text, default: "self"
    end

    alter table(:travel_policy_checks) do
      add :approval_mode, :text
    end

    alter table(:travel_change_orders) do
      add :approval_mode, :text, default: "self"
    end

    alter table(:travel_refund_orders) do
      add :approval_mode, :text, default: "self"
    end
  end

  def down do
    alter table(:travel_refund_orders) do
      remove :approval_mode
    end

    alter table(:travel_change_orders) do
      remove :approval_mode
    end

    alter table(:travel_policy_checks) do
      remove :approval_mode
    end

    alter table(:travel_policies) do
      remove :approval_mode
    end
  end
end
