defmodule Automedia.Nextcloud.Tag do
  @moduledoc false

  require Logger

  @enforce_keys ~w(database database_prefix host password username tag)a
  defstruct [
    :database,
    :database_prefix,
    :match,
    :host,
    :password,
    :tag,
    :username,
    dry_run: false,
    path_prefix: "/"
  ]

  def run(%__MODULE__{} = options) do
    {:ok, pid} = Postgrex.start_link(
      hostname: options.host,
      database: options.database,
      username: options.username,
      password: options.password
    )
    tags_table = "#{options.database_prefix}systemtag"
    files_table = "#{options.database_prefix}filecache"

    tag = Postgrex.query!(pid, "select id from #{tags_table} where name = $1", [options.tag])
    tag_id = if length(tag.rows) > 0 do
      hd(hd(tag.rows))
    else
      create_tag(pid, options.tag, options)
    end
    match = "%#{options.match || options.tag}%"
    path_match = "files#{options.path_prefix}%"

    query = """
    select fileid, path
    from #{files_table}
    where
      name ilike $1
      AND path like $2
      AND mimetype = 12
    """

    files = Postgrex.query!(pid, query, [match, path_match])
    Enum.each(files.rows, fn row ->
      [file_id, path] = row
      has = has_tag?(pid, file_id, tag_id, options)
      if has do
        Logger.debug("File '#{path}' already has tag '#{options.tag}', skipping")
      else
        if options.dry_run do
          Logger.info("Would apply tag '#{options.tag}' to file '#{path}'")
        else
          Logger.info("Applying tag '#{options.tag}' to file '#{path}'")
          tag_file(pid, file_id, tag_id, options)
        end
      end
    end)

    {:ok}
  end

  defp create_tag(pid, tag, options) do
    tags_table = "#{options.database_prefix}systemtag"
    result = Postgrex.query!(
      pid,
      "INSERT INTO #{tags_table} (name) VALUES ($1) RETURNING id",
      [tag]
    )
    hd(hd(result.rows))
  end

  defp has_tag?(pid, file_id, tag_id, options) do
    taggings_table = "#{options.database_prefix}systemtag_object_mapping"
    result = Postgrex.query!(
      pid,
      "select * from #{taggings_table} where objectid = $1 AND objecttype = 'files' AND systemtagid = $2",
      [Integer.to_string(file_id), tag_id]
    )
    result.num_rows > 0
  end

  defp tag_file(pid, file_id, tag_id, options) do
    taggings_table = "#{options.database_prefix}systemtag_object_mapping"
    Postgrex.query!(
      pid,
      "INSERT INTO #{taggings_table} (objectid, objecttype, systemtagid) VALUES  ($1, 'files', $2)",
      [Integer.to_string(file_id), tag_id]
    )
  end
end
