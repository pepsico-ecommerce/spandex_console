defmodule SpandexConsole do
  @moduledoc "See `SpandexConsole.Sender` for more information."

  defdelegate traces, to: SpandexConsole.Sender
  defdelegate spans, to: SpandexConsole.Sender
  defdelegate reset, to: SpandexConsole.Sender
end
