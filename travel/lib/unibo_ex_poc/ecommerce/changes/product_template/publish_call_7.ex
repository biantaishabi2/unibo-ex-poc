defmodule UniboExPoc.Ecommerce.Changes.ProductTemplate.PublishCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Ecommerce, :sanitize_html, 2) do
      Ecommerce.sanitize_html(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Ecommerce.sanitize_html/2")
    end
  end
end
