defmodule Automedia.Nextcloud.Tag do
  @moduledoc false

  @enforce_keys ~w(prefix tag database host username password)a
  defstruct ~w(prefix tag host database username password)a

  def run(%__MODULE__{} = options) do
    {:ok, pid} = Postgrex.start_link(
      hostname: options.host,
      database: options.database,
      username: options.username,
      password: options.password
    )
    tags_table = "#{options.prefix}systemtag"
    files_table = "#{options.prefix}filecache"

    tag = Postgrex.query!(pid, "select id from #{tags_table} where name = $1", [options.tag])
    tag_id = if length(tag.rows) > 0 do
      hd(hd(tag.rows))
    else
      create_tag(pid, options.tag, options)
    end
    match = "%#{options.tag}%"
    files = Postgrex.query!(pid, "select fileid from #{files_table} where name ilike $1", [match])
    Enum.each(files.rows, fn row ->
      file_id = hd(row)
      has = has_tag?(pid, file_id, tag_id, options)
      if !has do
        tag_file(pid, file_id, tag_id, options)
      end
    end)
    {:ok}
  end

  defp create_tag(pid, tag, options) do
    tags_table = "#{options.prefix}systemtag"
    result = Postgrex.query!(
      pid,
      "INSERT INTO #{tags_table} (name) VALUES ($1) RETURNING id",
      [tag]
    )
    hd(hd(result.rows))
  end

  defp has_tag?(pid, file_id, tag_id, options) do
    taggings_table = "#{options.prefix}systemtag_object_mapping"
    result = Postgrex.query!(
      pid,
      "select * from #{taggings_table} where objectid = $1 AND objecttype = 'files' AND systemtagid = $2",
      [Integer.to_string(file_id), tag_id]
    )
    result.num_rows > 0
  end

  defp tag_file(pid, file_id, tag_id, options) do
    taggings_table = "#{options.prefix}systemtag_object_mapping"
    Postgrex.query!(
      pid,
      "INSERT INTO #{taggings_table} (objectid, objecttype, systemtagid) VALUES  ($1, 'files', $2)",
      [Integer.to_string(file_id), tag_id]
    )
  end
end
