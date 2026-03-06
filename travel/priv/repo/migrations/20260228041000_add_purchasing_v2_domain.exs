defmodule UniboExPoc.Repo.Migrations.AddPurchasingV2Domain do
  @moduledoc """
  V2 应用层验证所需表结构：独立于 V1，避免影响已验收链路。
  """

  use Ecto.Migration

  def up do
    create table(:v2_parties, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :status, :text, null: false, default: "active"
      add :role, :text, null: false, default: "supplier"

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)
    end

    create table(:v2_products, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :internal_name, :text, null: false
      add :product_name, :text

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)
    end

    create unique_index(:v2_products, [:internal_name], name: "v2_products_internal_name_index")

    create table(:v2_orders, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :order_name, :text
      add :status, :text, null: false, default: "created"
      add :created_by_id, :uuid, null: false
      add :cost_amount, :decimal, null: false, default: "0"
      add :sell_amount, :decimal, null: false, default: "0"

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add :supplier_id,
          references(:v2_parties,
            column: :id,
            name: "v2_orders_supplier_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false
    end

    create table(:v2_order_items, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :seq_id, :bigint, null: false
      add :quantity, :decimal, null: false
      add :unit_price, :decimal, null: false
      add :subtotal, :decimal

      timestamps(type: :utc_datetime_usec, inserted_at: :inserted_at, updated_at: :updated_at)

      add :order_id,
          references(:v2_orders,
            column: :id,
            name: "v2_order_items_order_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :product_id,
          references(:v2_products,
            column: :id,
            name: "v2_order_items_product_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:v2_order_items, [:order_id, :seq_id], name: "v2_order_items_seq_unique")
  end

  def down do
    drop_if_exists unique_index(:v2_order_items, [:order_id, :seq_id],
                     name: "v2_order_items_seq_unique"
                   )

    drop constraint(:v2_order_items, "v2_order_items_order_id_fkey")
    drop constraint(:v2_order_items, "v2_order_items_product_id_fkey")
    drop table(:v2_order_items)

    drop constraint(:v2_orders, "v2_orders_supplier_id_fkey")
    drop table(:v2_orders)

    drop_if_exists unique_index(:v2_products, [:internal_name],
                     name: "v2_products_internal_name_index"
                   )

    drop table(:v2_products)

    drop table(:v2_parties)
  end
end
