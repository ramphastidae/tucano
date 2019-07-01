defmodule Mix.Tasks.Doc.Api.Server do
  use Mix.Task

  def run(args) do
    if Enum.empty?(args) || not valid_int?(List.first args) do
      Mix.shell.info "Needs to receive a Port for local preview server."
    else
      args |> create
    end
  end

  defp create(args) do
    Mix.Task.run "app.start"
    # Does not die after CTRL-C
    System.cmd("aglio", 
      [
        "-i", 
        "doc/api/DOCUMENTATION.md", 
        "-s",
        "-p",
        "#{List.first args}"
      ]
    )
  end

  defp valid_int?(int) do
    {i, _} = Integer.parse(int)
    is_integer(i)
  end
end
