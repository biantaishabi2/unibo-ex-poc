defmodule UniboExPocWeb.Layouts do
  @moduledoc """
  布局模块，提供 root 和 app 两个布局。
  """
  use UniboExPocWeb, :html

  embed_templates "layouts/*"
end
