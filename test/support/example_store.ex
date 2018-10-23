defmodule Mnesiac.Support.ExampleStore do
  @moduledoc false
  require Record

  Record.defrecord(
    :example,
    ExampleStore,
    id: nil,
    topic_id: nil,
    event: nil
  )

  @type example ::
          record(
            :example,
            id: String.t(),
            topic_id: String.t(),
            event: String.t()
          )

  def init_store do
    :mnesia.create_table(
      ExampleStore,
      attributes: example() |> example() |> Keyword.keys(),
      index: [:topic_id],
      disc_copies: [node()]
    )
  end

  def copy_store do
    :mnesia.add_table_copy(ExampleStore, node(), :disc_copies)
  end
end
