defmodule Mnesiac.Store do
  @moduledoc """
  Mnesia Store Manager
  """

  @doc """
  Init tables
  """
  def init_tables do
    case :mnesia.system_info(:extra_db_nodes) do
      [_head | _tail] ->
        copy_tables()

      [] ->
        create_tables()
    end
  end

  @doc """
  Ensure tables loaded
  """
  def ensure_tables_loaded do
    tables = :mnesia.system_info(:local_tables)

    case :mnesia.wait_for_tables(tables, table_load_timeout()) do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, reason}

      {:timeout, bad_tables} ->
        {:error, {:timeout, bad_tables}}
    end
  end

  @doc """
  Create tables
  """
  def create_tables do
    Enum.each(stores(), fn data_mapper ->
      apply(data_mapper, :init_store, [])
    end)

    :ok
  end

  @doc """
  Copy tables
  """
  def copy_tables do
    Enum.each(stores(), fn data_mapper ->
      apply(data_mapper, :copy_store, [])
    end)

    :ok
  end

  @doc """
  Copy schema
  """
  def copy_schema(cluster_node) do
    copy_type = Application.get_env(:mnesiac, :schema_type, :ram_copies)

    case :mnesia.change_table_copy_type(:schema, cluster_node, copy_type) do
      {:atomic, :ok} ->
        :ok

      {:aborted, {:already_exists, :schema, _, _}} ->
        :ok

      {:aborted, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Delete schema
  """
  def delete_schema do
    :mnesia.delete_schema([node()])
  end

  @doc """
  Delete schema copy
  """
  def del_schema_copy(cluster_node) do
    case :mnesia.del_table_copy(:schema, cluster_node) do
      {:atomic, :ok} ->
        :ok

      {:aborted, reason} ->
        {:error, reason}
    end
  end

  defp stores do
    Application.get_env(:mnesiac, :stores)
  end

  defp table_load_timeout do
    Application.get_env(:mnesiac, :table_load_timeout, 600_000)
  end
end
