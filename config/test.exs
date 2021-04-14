import Config

config :spandex_console,
  silent: true,
  record: true

config :spandex_console, SpandexConsole.TestTracer,
  adapter: SpandexConsole.Adapter,
  service: :"test-service",
  disabled?: false,
  env: "test"
