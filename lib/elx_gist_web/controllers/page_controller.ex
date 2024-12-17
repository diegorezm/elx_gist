defmodule ElxGistWeb.PageController do
  use ElxGistWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/gist/create")
  end
end
