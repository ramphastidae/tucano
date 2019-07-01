defmodule Tupi.EctoEnums do

  import EctoEnum
  defenum TypesEnum, admin: 0, manager: 1, normal: 2

  defenum StatusEnum, active: 1, inactive: 2

  defenum StagesEnum, submission: 1, assigned: 2

  defenum IncoherenceEnum, unviewed: 1, viewed: 2, solved: 3

  defenum ContestEnum, unpublished: 1, published: 2
end
