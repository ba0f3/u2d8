import ../rethinkdb.nim/rethinkdb, sam, os, strutils, tables, times, asyncdispatch
import private/types, private/engines/engine_nre


proc parseFormula(path: string): Formula =
  if not fileExists(path):
    raise newException(IOError, "Formula file $# does not exist" % path)
  result.loads(readFile(path))

proc getVersion(formula: Formula): string =
  result = ""
  case formula.engine
  of NRE:
    result = engine_nre.fetchVersion(formula)
  else:
    raise newException(ValueError, "Engine $# is not defined yet" % $formula.engine)

proc loadForumlas(): Table[string, Formula] =
  ## Load all defined formulas for syntax checking...
  result = initTable[string, Formula]()
  var formula: Formula

  for file in walkFiles("formula/*.json"):
    try:
      formula = parseFormula(file)
      result[formula.name] = formula
    except Exception as ex:
      echo "Unable to parse formular file $#: $#" % [file, ex.msg]

proc update() =
  var formulas = loadForumlas()
  for k, f in formulas.pairs():
    #var s = &*{"id": k, "name":  f.name, "description": f.desc, "homepage": f.homepage, "tags": f.tags, "version": "0.1.0", "lastCheckedAt": getLocalTime(getTime())}
    try:
      echo f.name, " => ", getVersion(f)
      #discard waitFor r.table("Software").insert([s]).run(r)
    except Exception as ex:
      echo "Unable to get version for $#: $#" % [f.name, ex.msg]

  #r.close()

when isMainModule:
  update()
