defmodule Tupi.Ads.Setting do
  use Memento.Table,
    attributes: [:type_key, :allocations, :occupied],
    type: :ordered_set,
    autoincrement: true
end
