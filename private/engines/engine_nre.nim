import httpclient, nre, options, strutils, ../types

const NRE_VERSION_PATTERN = r"(?<version>\d+(?:\.\d+)+)"

proc fetchVersion*(formula: Formula): string =
  let content = getContent(formula.url)
  let m = content.match(re(replace(formula.pattern, "[VERSION]", NRE_VERSION_PATTERN)))
  if isSome(m):
    result = m.unsafeGet().captures["version"]
  else:
    raise newException(ValueError, "Unable to find version for $#" % formula.name)
