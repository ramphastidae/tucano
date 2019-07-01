{:ok, _} = Application.ensure_all_started(:ex_machina)
Bureaucrat.start(
  writer: Bureaucrat.ApiBlueprintWriter,
  default_path: "doc/API/DOCUMENTATION.md",
  paths: [],
  titles: [],
  env_var: "DOC",
  json_library: Jason
)
ExUnit.start(formatters: [ExUnit.CLIFormatter, Bureaucrat.Formatter])
TupiWeb.ConnCaseHelper.contest_setup()
Ecto.Adapters.SQL.Sandbox.mode(Tupi.Repo, :manual)
