import rethinkengine, times

type
  Software* = object of RethinkDocument
    name*: string
    description*: string
    homepage*: string
    tags*: seq[string]
    version*: string
    lastCheckedAt*: TimeInfo

  VersionHistory* = object of RethinkDocument
    version*: string
    updatedAt*: TimeInfo
