import std/times

type Entry* = object
  id*: int
  name*: string
  lugar*: string
  date*: DateTime
  path*: string

const entryDateFormat* = "yyyy-MM-dd hh:mm:ss"
