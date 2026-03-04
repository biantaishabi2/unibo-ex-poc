%{rows: rows} = Ecto.Adapters.SQL.query!(UniboV4.Repo,
  "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name")
IO.puts("Total public tables: #{length(rows)}")

# Check which no_table domains are still missing
missing_check = [
  "calendar_calendars", "calendar_work_schedules", "calendar_week_templates",
  "events_event_types", "events_events", "fleet_fleet_vehicles",
  "loyalty_coupons", "payment_payments", "delivery_shipments",
  "loyalty_gift_cards", "loyalty_loyalty_programs"
]

Enum.each(missing_check, fn t ->
  exists = Enum.any?(rows, fn [name] -> name == t end)
  IO.puts("  #{t}: #{if exists, do: "EXISTS", else: "MISSING"}")
end)
