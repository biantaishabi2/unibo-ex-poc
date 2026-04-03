p = Ash.get!(HospitalScheduling.Scheduling.SchedulingPeriod, "62041f94-0d41-41aa-acfe-b054e45dba9e", authorize?: false)
IO.puts("state: #{p.state}")

result = Ash.update(Ash.Changeset.for_update(p, :publish, %{}), authorize?: false)
case result do
  {:ok, u} -> IO.puts("PUBLISHED: #{u.state}")
  {:error, e} -> IO.puts("PUBLISH_ERROR: #{inspect(e, limit: 500)}")
end
