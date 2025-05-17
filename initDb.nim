import std/[os, strutils, logging]

import db_connector/db_sqlite

proc initDb*() =
  if not fileExists("aves.db"):
    let
      db = open("aves.db", "", "", "")
      schema = readFile("schema.sql")
    for line in schema.split(";"):
      if line == "\c\n" or line == "\n":
        continue
      db.exec(sql(line.strip))
    #echo db.getAllRows()
    db.close()
    #logging.info("Initialized the database.")
