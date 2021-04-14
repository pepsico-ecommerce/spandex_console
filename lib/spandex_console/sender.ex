defmodule SpandexConsole.Sender do
  @moduledoc "Console tracer sender for Spandex."
  use Agent

  alias Spandex.{Trace, Span}

  @spec send_trace(Trace.t(), Keyword.t()) :: any()
  def send_trace(%Trace{} = trace, _opts \\ []) do
    if Application.get_env(:spandex_console, :record) do
      Agent.update(__MODULE__, &[trace | &1])
    end

    unless Application.get_env(:spandex_console, :silent) do
      IO.puts(prettify_trace(trace))
    end
  end

  defp prettify_trace(%Trace{} = trace) do
    spans = Enum.sort_by(trace.spans, & &1.id)

    IO.ANSI.format(
      [
        ?\n,
        :cyan,
        "-- BEGIN TRACE ##{trace.id}"
      ] ++
        Enum.map(spans, fn span ->
          [
            ?\n,
            :green,
            "  -- BEGIN SPAN ##{span.id}",
            :faint,
            " [#{span.name || "--"}]",
            ?\n,
            :white,
            "     service: #{span.service || "--"}",
            ?\n,
            "     resource: #{trim(span.resource || "--")}",
            ?\n,
            "     tags: #{trim(inspect(span.tags))}",
            ?\n,
            :reset,
            :green,
            "  -- END SPAN ##{span.id}"
          ]
        end) ++
        [
          ?\n,
          :cyan,
          "-- END TRACE",
          :reset,
          ?\n
        ]
    )
  end

  @max_length 80
  defp trim(str) do
    if String.length(str) > @max_length do
      String.slice(str, 0..@max_length) <> "..."
    else
      str
    end
  end

  # ---

  def start_link(_), do: Agent.start_link(&default_state/0, name: __MODULE__)

  @doc false
  def default_state(_ \\ nil), do: []

  @doc "Clear all stored traces and spans."
  @spec reset :: :ok
  def reset, do: Agent.update(__MODULE__, &default_state/1)

  @doc "Get a list of all sent traces (earliest first)."
  @spec traces :: [Trace.t()]
  def traces do
    assert_recording!()
    Agent.get(__MODULE__, &Enum.reverse/1)
  end

  @doc "Get a list of all sent spans (earlist parent trace first)."
  @spec spans :: [Span.t()]
  def spans do
    assert_recording!()

    Agent.get(__MODULE__, fn state ->
      state
      |> Enum.reverse()
      |> Enum.flat_map(& &1.spans)
    end)
  end

  defp assert_recording! do
    unless Application.get_env(:spandex_console, :record) do
      raise """
      Traces and spans aren't recorded unless `:record` is enabled. To fix:

          # config.exs
          config :spandex_console,
            record: true

      """
    end
  end
end
