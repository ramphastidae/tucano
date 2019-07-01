defmodule Tupi.Ads.Code do
  use Memento.Table,
    attributes: [:id, :code],
    type: :ordered_set,
    autoincrement: true
end
