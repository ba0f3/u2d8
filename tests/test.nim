import ../private/models
import ../../rethinkengine.nim/rethinkengine
import marshal
import ../../rethinkdb.nim/rethinkdb
import tables
import json
import asyncdispatch


var r = newRethinkClient()
waitFor r.connect()

var soft: Software

soft.id = "nginx"
soft.name = "nginx"

r.save(soft)

r.close()
