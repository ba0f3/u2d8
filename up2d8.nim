import rethinkdb, xxhash, sam, os, strutils, tables, times, asyncdispatch
import private/types, private/engines/engine_nre

#type
#  fetchVersion*: proc(formula: Formula): string {.nimcall, gcsafe.}

proc parseFormula(path: string): Formula =
  if not fileExists(path):
    raise newException(FormulaNotFoundEception, "Formula file $# does not exist" % path)
  result.loads(readFile(path))

proc getVersion(formula: Formula): string =
  result = ""
  case formula.engine
  of NRE:
    result = engine_nre.fetchVersion(formula)
  else:
    raise newException(EngineNotFoundException, "Engine $# is not defined yet" % $formula.engine)

proc loadForumlas(): Table[string, Formula] =
  ## Load all defined formulas for syntax checking...
  result = initTable[string, Formula]()
  var formula: Formula

  for file in walkFiles("formula/*.json"):
    formula = parseFormula(file)
    result[formula.name] = formula

proc update() =
  var formulas = loadForumlas()
  for k, f in formulas.pairs():
    #var s = &*{"id": k, "name":  f.name, "description": f.desc, "homepage": f.homepage, "tags": f.tags, "version": "0.1.0", "lastCheckedAt": getLocalTime(getTime())}
    echo f.name, " => ", getVersion(f)
    #discard waitFor r.table("Software").insert([s]).run(r)

  #r.close()

when isMainModule:
  update()
