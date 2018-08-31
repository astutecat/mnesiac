use Mix.Config

config :mnesia, dir: to_charlist(Path.join(File.cwd!(), List.first(String.split(to_string(Node.self()), "@"))))

config :mnesiac,
  stores: [Mnesiac.Support.ExampleStore],
  schema_type: :disc_copies,
  table_load_timeout: 600_000
