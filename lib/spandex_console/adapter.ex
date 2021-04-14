defmodule SpandexConsole.Adapter do
  @moduledoc "Console tracer adapter for Spandex."
  use Agent

  @behaviour Spandex.Adapter

  @impl true
  def default_sender, do: SpandexConsole.Sender

  @impl true
  def trace_id do
    Agent.get_and_update(__MODULE__, fn %{trace: next} = state ->
      {next, Map.put(state, :trace, next + 1)}
    end)
  end

  @impl true
  def span_id do
    Agent.get_and_update(__MODULE__, fn %{span: next} = state ->
      {next, Map.put(state, :span, next + 1)}
    end)
  end

  @impl true
  def now, do: :os.system_time(:nano_seconds)

  @impl true
  def inject_context(headers, _context, _opts), do: headers

  @impl true
  def distributed_context(_headers, _opts), do: {:error, :no_distributed_context}

  # ---

  def start_link(_), do: Agent.start_link(&default_state/0, name: __MODULE__)

  def reset, do: Agent.update(__MODULE__, &default_state/1)

  def default_state(_ \\ nil), do: %{trace: 1, span: 1}
end
