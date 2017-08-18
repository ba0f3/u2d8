import ../rethinkdb.nim/rethinkdb, sam, os, strutils, tables, times, asyncdispatch, threadpool
import private/types, private/engines/engine_nre

var done = false

proc parseFormula(path: string): Formula =
  if not fileExists(path):
    raise newException(IOError, "Formula file $# does not exist" % path)
  result.loads(readFile(path))

proc getVersion(formula: Formula): Future[string] {.async.} =
  result = ""
  case formula.engine
  of NRE:
    var fut = engine_nre.fetchVersion(formula)
    yield fut
    if fut.failed:
      raise fut.error
    else:
      result = fut.read
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

proc update(): Future[void] {.async.} =
  var formulas = loadForumlas()
  for k, f in formulas.pairs():
    #var s = &*{"id": k, "name":  f.name, "description": f.desc, "homepage": f.homepage, "tags": f.tags, "version": "0.1.0", "lastCheckedAt": getLocalTime(getTime())}
    var fut = getVersion(f)
    yield fut
    if fut.failed:
      echo "Unable to get version for $#: $#" % [f.name, fut.error.msg]
    else:
      let version = fut.read
      echo f.name, " => ", version

      #discard waitFor r.table("Software").insert([s]).run(r)
  #r.close()
  done = true

when isMainModule:
  asyncCheck update()
  while not done:
    poll()
  #runForever()
