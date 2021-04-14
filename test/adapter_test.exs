defmodule SpandexConsole.AdapterTest do
  use ExUnit.Case, async: false

  alias SpandexConsole.Adapter

  setup do
    start_supervised!(SpandexConsole.Adapter)

    :ok
  end

  test "trace_id/0" do
    assert Adapter.trace_id() == 1
    assert Adapter.trace_id() == 2
    assert Adapter.trace_id() == 3

    # reset state
    assert Adapter.reset() == :ok

    assert Adapter.trace_id() == 1

    # incrementing span ID doesn't affect trace ID
    _ = Adapter.span_id()
    assert Adapter.trace_id() == 2
  end

  test "span_id/0" do
    assert Adapter.span_id() == 1
    assert Adapter.span_id() == 2
    assert Adapter.span_id() == 3

    # reset state
    assert Adapter.reset() == :ok

    assert Adapter.span_id() == 1

    # incrementing trace ID doesn't affect span ID
    _ = Adapter.trace_id()
    assert Adapter.span_id() == 2
  end
end
