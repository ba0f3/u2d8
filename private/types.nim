import times

type
  EngineType* = enum
    NRE

  Formula* = object
    name*: string
    desc*: string
    homepage*: string
    tags*: seq[string]
    url*: string
    pattern*: string
    engine*: EngineType

    lastUpdated: TimeInfo


  EngineNotFoundException* = IOError
  FormulaNotFoundEception* = IOError
