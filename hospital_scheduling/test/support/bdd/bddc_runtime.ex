defmodule HospitalScheduling.BDDC.Runtime do
  @moduledoc false

  defmacro __using__(opts) do
    common_mod = Keyword.fetch!(opts, :common_module)

    quote do
      use UniboBddRuntime.Macro, common_module: unquote(common_mod)
    end
  end
end
