import os, asyncdispatch, httpclient, nre, options, strutils, ../types

const NRE_VERSION_PATTERN = r"(?<version>\d+(?:\.\d+)+)"

proc fetchVersion*(formula: Formula): Future[string] {.async.} =
  when defined(cachedOn):
    let cached = "cached/$#.html" % formula.name
    var content: string
    if cached.fileExists:
      content = readFile(cached)
    else:
      var client = newAsyncHttpClient()
      echo formula.url
      var
        fut = client.getContent(formula.url)
      yield fut
      if fut.failed:
        raise fut.error
      else:
        writeFile(cached, fut.read)
  else:
    let
      client = newAsyncHttpClient()
      fut = client.getContent(formula.url)
    yield fut
    if fut.failed:
      raise fut.error
    let content = fut.read
  let m = content.match(re(replace(formula.pattern, "[VERSION]", NRE_VERSION_PATTERN)))
  if isSome(m):
    result = m.unsafeGet().captures["version"]
  else:
    raise newException(ValueError, "Unable to find version for $#" % formula.name)
