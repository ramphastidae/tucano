# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tupi.Repo.insert!(%Tupi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Tupi.Accounts.create_admin(%{email: "admin@tupi.pi", password: "admin123"})

# Import environment specific seeds. This must remain at the bottom
# of this file.
Code.eval_file("seeds_#{Mix.env()}.exs", "./priv/repo/")
