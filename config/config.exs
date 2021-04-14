import Config

config :spandex_console,
  silent: false,
  record: false

import_config "#{Mix.env()}.exs"
