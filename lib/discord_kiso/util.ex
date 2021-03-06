defmodule DiscordKiso.Util do
  def pull_id(message) do
    id = Regex.run(~r/([0-9])\w+/, message)

    case id do
      nil -> nil
      id -> List.first(id)
    end
  end

  def one_to(n), do: Enum.random(1..n) <= 1
  def percent(n), do: Enum.random(1..100) <= n

  def download(url) do
    require Logger

    filename = url |> String.split("/") |> List.last
    filepath = "_tmp/#{filename}"

    Logger.log :info, "Downloading #{filename}..."
    image = url |> HTTPoison.get!
    File.write filepath, image.body

    filepath
  end

  def is_dupe?(source, filename) do
    require Logger

    Logger.info "Checking if #{filename} was last posted..."
    file = query_data("dupes", source)

    cond do
      file == nil ->
        store_data("dupes", source, filename)
        false
      file != filename ->
        store_data("dupes", source, filename)
        false
      file == filename -> true
      true -> nil
    end
  end

  def is_image?(url) do
    require Logger

    Logger.log :info, "Checking if #{url} is an image..."
    image_types = [".jpg", ".jpeg", ".gif", ".png", ".mp4"]
    Enum.member?(image_types, Path.extname(url))
  end

  def titlecase(title, mod) do
    words = title |> String.split(mod)

    for word <- words do
      word |> String.capitalize
    end |> Enum.join(" ")
  end

  def store_data(table, key, value) do
    file = '_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])

    :dets.insert(table, {key, value})
    :dets.close(table)
    :ok
  end

  def query_data(table, key) do
    file = '_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    result = :dets.lookup(table, key)

    response =
      case result do
        [{_, value}] -> value
        [] -> nil
      end

    :dets.close(table)
    response
  end

  def query_all_data(table) do
    file = '_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    result = :dets.match_object(table, {:"$1", :"$2"})

    response =
      case result do
        [] -> nil
        values -> values
      end

    :dets.close(table)
    response
  end

  def delete_data(table, key) do
    file = '_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    response = :dets.delete(table, key)

    :dets.close(table)
    response
  end
end
