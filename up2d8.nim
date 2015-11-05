import pegs, marshal, q


type
  Formula = ref object
    name: string
    desc: string
    homepage: string
    url: string
    pattern: string
    parser: string



when isMainModule:
  var f: Formula
  f = to(readFile("formula/nginx.json"))
  echo f
