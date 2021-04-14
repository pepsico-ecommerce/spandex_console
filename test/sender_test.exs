defmodule SpandexConsole.SenderTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  alias SpandexConsole.{Sender, TestTracer}

  require TestTracer

  setup do
    start_supervised!(SpandexConsole.Adapter)
    start_supervised!(SpandexConsole.Sender)

    :ok
  end

  describe "send_trace/2" do
    setup do
      Application.put_env(:spandex_console, :silent, false)

      on_exit(fn ->
        Application.put_env(:spandex_console, :silent, true)
      end)
    end

    test "generates correct output" do
      trace = %Spandex.Trace{
        id: 1,
        spans: [
          %Spandex.Span{
            id: 1,
            service: :"test-service-api",
            resource: "",
            tags: []
          },
          %Spandex.Span{
            id: 2,
            service: :"test-service-db",
            resource: "",
            tags: [async: true]
          }
        ]
      }

      assert capture_io(fn ->
               Sender.send_trace(trace)
             end) == """

             \e[36m-- BEGIN TRACE #1
             \e[32m  -- BEGIN SPAN #1\e[2m [--]
             \e[37m     service: test-service-api
                  resource: \n     tags: []
             \e[0m\e[32m  -- END SPAN #1
             \e[32m  -- BEGIN SPAN #2\e[2m [--]
             \e[37m     service: test-service-db
                  resource: \n     tags: [async: true]
             \e[0m\e[32m  -- END SPAN #2
             \e[36m-- END TRACE\e[0m
             \e[0m
             """
    end
  end

  test "traces/0" do
    TestTracer.start_trace("test-span", [])
    TestTracer.finish_trace()

    traces = SpandexConsole.traces()
    assert length(traces) == 1
  end

  test "spans/0" do
    TestTracer.start_trace("test-span", [])
    TestTracer.finish_trace()

    spans = SpandexConsole.spans()
    assert length(spans) == 1
  end
end
