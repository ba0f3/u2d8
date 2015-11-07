import pegs, marshal, q, options, os, strutils, httpclient, nre, tables

const
  NRE_VERSION_PATTERN = r"(?<version>\d+(?:\.\d+)+)"

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

  if result.url == "":
    raise newException(ValueError, "URL for $# cannot be null or empty" % result.name)

proc getVersion(formula: Formula): string =
  result = ""

  let content = getContent(formula.url)
  if formula.engine == "nre":
    let m = content.match(re(replace(formula.pattern, "[VERSION]", NRE_VERSION_PATTERN)))
    if isSome(m):
      result = m.unsafeGet().captures["version"]
    else:
      raise newException(ValueError, "Unable to find version for $#" % formula.name)
  else:
    raise newException(EngineNotFoundException, "Engine $# is not defined yet" % formula.engine)

proc loadForumlas(): Table[string, Formula] =
  ## Load all defined formulas for syntax checking...
  result = initTable[string, Formula]()
  var formula: Formula

  for file in walkFiles("formula/*.json"):
    formula = getFormula(file)
    result[formula.name] = formula

proc update() =
  var formulas = loadForumlas()
  for f in formulas.values():
    echo f.name, " => ", getVersion(f)

when isMainModule:
  update()
