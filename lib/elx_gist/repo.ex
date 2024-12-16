defmodule ElxGist.Repo do
  use Ecto.Repo,
    otp_app: :elx_gist,
    adapter: Ecto.Adapters.Postgres
end
