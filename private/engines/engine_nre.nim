import os, httpclient, nre, options, strutils, ../types

const NRE_VERSION_PATTERN = r"(?<version>\d+(?:\.\d+)+)"

proc fetchVersion*(formula: Formula): string =
  let
    client = newHttpClient()
    cached = "cached/$#.html" % formula.name

  when defined(cachedOn):
    var content: string
    if cached.fileExists:
      content = readFile(cached)
    else:
      content = client.getContent(formula.url)
      writeFile(cached, content)
  else:
    let content = client.getContent(formula.url)
  let m = content.match(re(replace(formula.pattern, "[VERSION]", NRE_VERSION_PATTERN)))
  if isSome(m):
    result = m.unsafeGet().captures["version"]
  else:
    raise newException(ValueError, "Unable to find version for $#" % formula.name)
