include nre, options

#let pattern = ".+ 'Stable version' .+ '/CHANGES-' {.*} .+"
#let pattern = "Stable.*?CHANGES-([0-9\\.]+)"

let html = $(readFile("nginx.html"))

echo html.match(re"(?m)Stable.*?CHANGES-(?<version>[0-9\\.]+)").get().str

#echo "abc".match(re"(\w)").get.captures[0] == "a"
