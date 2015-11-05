import pegs, marshal, q, options, os, strutils, httpclient, nre


type
  Formula = object
    name: string
    desc: string
    homepage: string
    url: string
    pattern: string
    engine: string

  EngineNotFoundException = IOError



proc getFormula(name: string): Formula =
  let file = "formula/$#.json" % name
  if not fileExists(file):
    raise newException(IOError, "Formula file $# does not exist" % file)
  result = to[Formula](readFile(file))

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


when isMainModule:
  var f = getFormula("nginx")

  echo getVersion(f)
