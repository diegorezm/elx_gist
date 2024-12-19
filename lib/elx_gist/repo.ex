defmodule ElxGist.Repo do
  use Ecto.Repo,
    otp_app: :elx_gist,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 5
end
