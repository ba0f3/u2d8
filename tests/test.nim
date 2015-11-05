import nre, options

#let pattern = ".+ 'Stable version' .+ '/CHANGES-' {.*} .+"
#let pattern = "Stable.*?CHANGES-([0-9\\.]+)"

let html = readFile("nginx.html")

let m = html.match(re"(?s).+Stable.+?CHANGES\-(?<version>[0-9\.]+)")
if isSome(m):
  echo m.unsafeGet().captures["version"]
