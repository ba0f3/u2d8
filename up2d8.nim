import pegs, marshal, q, options, os, strutils, httpclient, nre, tables


type
  Formula = object
    name: string
    desc: string
    homepage: string
    url: string
    pattern: string
    engine: string

  EngineNotFoundException = IOError
  FormulaNotFoundEception = IOError

proc getFormula(path: string): Formula =
  if not fileExists(path):
    raise newException(FormulaNotFoundEception, "Formula file $# does not exist" % path)
  result = to[Formula](readFile(path))

proc getVersion(formula: Formula): string =
  result = ""
  let content = getContent(formula.url)

  if formula.engine == "nre":
    let m = content.match(re(formula.pattern))
    if isSome(m):
      result = m.unsafeGet().captures["version"]
    else:
      raise newException(ValueError, "Unable to find version for $#" % formula.name)
  else:
    raise newException(EngineNotFoundException, "Engine $# is not defined yet" % formula.engine)


proc update() =
  ## Load all defined formulas for syntax checking...
  var
    formulas = initTable[string, Formula]()
    formula: Formula

  for file in walkFiles("formula/*.json"):
      formula = getFormula(file)
      formulas[formula.name] = formula


#    echo formula.name, ", ", getVersion(formula)

when isMainModule:
  update()
