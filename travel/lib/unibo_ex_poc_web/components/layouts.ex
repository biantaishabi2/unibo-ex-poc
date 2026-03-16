defmodule UniboExPocWeb.Layouts do
  @moduledoc """
  Layout 模块，嵌入 layouts/ 下的模板。
  """
  use UniboExPocWeb, :html

  embed_templates "layouts/*"
end
