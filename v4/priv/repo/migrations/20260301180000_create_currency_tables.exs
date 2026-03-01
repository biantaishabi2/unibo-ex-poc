defmodule UniboV4.Repo.Migrations.CreateCurrencyTables do
  use Ecto.Migration

  def change do
    create table(:currency_currencies, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :code, :text, null: false
      add :name, :text, null: false
      add :symbol, :text
      add :decimal_places, :bigint, default: 2
      add :active, :boolean, default: true

      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:currency_currencies, [:code])

    create table(:currency_currency_translations, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :locale, :text, null: false
      add :field_name, :text, null: false
      add :value, :text
      add :currency_id, references(:currency_currencies, type: :uuid, on_delete: :delete_all), null: false

      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:currency_currency_translations, [:currency_id, :locale, :field_name])

    create table(:currency_rates, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :rate, :decimal, null: false
      add :effective_date, :date, null: false
      add :source, :text
      add :from_currency_id, references(:currency_currencies, type: :uuid), null: false
      add :to_currency_id, references(:currency_currencies, type: :uuid), null: false

      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:currency_rates, [:from_currency_id, :to_currency_id, :effective_date])
  end
end
