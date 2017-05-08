defmodule ElixirElmBootstrap.EventController do
  use ElixirElmBootstrap.Web, :controller
  use Guardian.Phoenix.Controller

  alias ElixirElmBootstrap.Event

  def index(conn, _params, user, _) do
    events = Repo.all(user_events(user))
    render(conn, "index.json", events: events)
  end

  def create(conn, %{"event" => event_params}, user, _) do

    changeset = Event.changeset(%Event{}, Map.put(event_params, "user_id", user.id))

    case Repo.insert(changeset) do
      {:ok, event} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", event_path(conn, :show, event))
        |> render("show.json", event: event)

        ElixirElmBootstrap.EventChannel.broadcast()

        conn

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ElixirElmBootstrap.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _, _) do
    event = Repo.get!(Event, id)
    render(conn, "show.json", event: event)
  end

  def update(conn, %{"id" => id, "event" => event_params}, _, _) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event, event_params)

    case Repo.update(changeset) do
      {:ok, event} ->
        render(conn, "show.json", event: event)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ElixirElmBootstrap.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _, _) do
    event = Repo.get!(Event, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event)

    send_resp(conn, :no_content, "")
  end

  defp user_events(user) do
    assoc(user, :events)
  end

end
