defmodule UniboExPoc.Repo.Migrations.AddPurchasingV3Domain do
  @moduledoc """
  V3 采购规则验证表结构：金额分级审批 + 风险供应商。
  """

  use Ecto.Migration

  def up do
    create table(:v3_parties, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:name, :text, null: false)
      add(:status, :text, null: false, default: "active")
      add(:risk_level, :text, null: false, default: "low")
      add(:is_blocked, :boolean, null: false, default: false)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)
    end

    create table(:v3_orders, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:order_name, :text, null: false)
      add(:status, :text, null: false, default: "created")
      add(:total_amount, :decimal, null: false, default: "0")
      add(:created_by_id, :uuid, null: false)

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add(
        :supplier_id,
        references(:v3_parties,
          column: :id,
          name: "v3_orders_supplier_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        null: false
      )
    end
  end

  def down do
    drop(constraint(:v3_orders, "v3_orders_supplier_id_fkey"))
    drop(table(:v3_orders))
    drop(table(:v3_parties))
  end
end
