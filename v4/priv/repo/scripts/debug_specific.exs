# 调查几个典型失败案例

# 1. required_argument: Approvals.ApprovalRequest.create 的 category_id
IO.puts("=== Approvals.ApprovalRequest ===")
resource = UniboV4.Approvals.ApprovalRequest
action = Ash.Resource.Info.action(resource, :create)
IO.puts("accept: #{inspect(action.accept)}")
IO.puts("arguments:")
Enum.each(action.arguments, fn arg ->
  IO.puts("  #{arg.name}: type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end)
IO.puts("MR changes:")
Enum.each(action.changes, fn
  %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
    IO.puts("  MR: arg=#{inspect(Keyword.get(opts, :argument))} rel=#{inspect(Keyword.get(opts, :relationship))} opts=#{inspect(Keyword.get(opts, :opts, []))}")
  _ -> :ok
end)
IO.puts("belongs_to:")
Enum.each(Ash.Resource.Info.relationships(resource), fn rel ->
  if rel.type == :belongs_to do
    IO.puts("  #{rel.name}: fk=#{rel.source_attribute} dest=#{inspect(rel.destination)} allow_nil?=#{rel.allow_nil?}")
  end
end)

# 2. must_be_present: Delivery.Shipment 的 shipment_type_id
IO.puts("\n=== Delivery.Shipment ===")
resource2 = UniboV4.Delivery.Shipment
action2 = Ash.Resource.Info.action(resource2, :create)
IO.puts("accept: #{inspect(action2.accept)}")
IO.puts("Present validations:")
Enum.each(action2.changes, fn
  %{validation: {Ash.Resource.Validation.Present, opts}} ->
    IO.puts("  Present: #{inspect(opts)}")
  _ -> :ok
end)
IO.puts("belongs_to:")
Enum.each(Ash.Resource.Info.relationships(resource2), fn rel ->
  if rel.type == :belongs_to do
    IO.puts("  #{rel.name}: fk=#{rel.source_attribute} dest=#{inspect(rel.destination)} allow_nil?=#{rel.allow_nil?}")
  end
end)

# 3. relate_actor_nil_rel: Blog.BlogPost
IO.puts("\n=== Blog.BlogPost ===")
resource3 = UniboV4.Blog.BlogPost
action3 = Ash.Resource.Info.action(resource3, :create)
IO.puts("RelateActor changes:")
Enum.each(action3.changes, fn
  %{change: {Ash.Resource.Change.RelateActor, opts}} ->
    rel_name = Keyword.get(opts, :relationship)
    IO.puts("  RelateActor: relationship=#{inspect(rel_name)} allow_nil?=#{inspect(Keyword.get(opts, :allow_nil?))}")
    # 查找关系
    rels = Ash.Resource.Info.relationships(resource3)
    rel = Enum.find(rels, &(&1.name == rel_name))
    IO.puts("  Found by name: #{inspect(rel && rel.name)}")
    rel2 = Enum.find(rels, &(&1.source_attribute == rel_name))
    IO.puts("  Found by source_attr: #{inspect(rel2 && rel2.name)}")
  _ -> :ok
end)
IO.puts("All relationships:")
Enum.each(Ash.Resource.Info.relationships(resource3), fn rel ->
  IO.puts("  #{rel.type} #{rel.name}: src_attr=#{inspect(rel.source_attribute)}")
end)

# 4. required_attribute: id — Studio.App
IO.puts("\n=== Studio.App ===")
resource4 = UniboV4.Studio.App
action4 = Ash.Resource.Info.action(resource4, :create)
IO.puts("accept: #{inspect(action4.accept)}")
id_attr = Ash.Resource.Info.attribute(resource4, :id)
IO.puts("id attr: type=#{inspect(id_attr.type)} default=#{inspect(id_attr.default)} primary_key?=#{id_attr.primary_key?} allow_nil?=#{id_attr.allow_nil?}")
