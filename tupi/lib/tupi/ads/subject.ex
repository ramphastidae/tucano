defmodule Tupi.Ads.Subject do
  use Memento.Table,
    attributes: [:id, :openings, :occupied],
    type: :ordered_set,
    autoincrement: true
end
