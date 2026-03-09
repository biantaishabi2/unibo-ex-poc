defmodule UniboExPoc.BDDC.Runtime do
  @moduledoc false

  defmacro __using__(opts) do
    common_mod = Keyword.fetch!(opts, :common_module)

    quote do
      @common_module unquote(common_mod)

      def capabilities do
        MapSet.new() |> MapSet.union(@common_module.capabilities())
      end

      # For runtime.caps.sync: keep an explicit, machine-readable pattern surface.
      # When you add new instructions, append a clause here.
      def __caps_sync_fixture__(tuple) do
        case tuple do
          {:given, :create_temp_dir} -> :ok
          {:given, :create_temp_file} -> :ok
          {:when, :noop} -> :ok
          {:then, :assert_noop} -> :ok
        end
      end

      def new_run_id do
        Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
      end

      def get!(ctx, key, meta) when is_map(ctx) and is_atom(key) do
        case Map.fetch(ctx, key) do
          {:ok, v} -> v
          :error -> raise "missing ctx var: #{inspect(key)} meta=#{inspect(meta)}"
        end
      end

      def run_step!(ctx, kind, name, args, meta, _dsl_line)
          when is_map(ctx) and kind in [:given, :when, :then] and is_atom(name) and is_map(args) do
        @common_module.run!(ctx, kind, name, args, meta)
      end
    end
  end
end
