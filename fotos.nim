# TODO: Eliminar variables globales
# TODO: Crear un objeto entry....
import
  std/[
    os, osproc, sequtils, strformat, files, strutils, tables, algorithm, enumerate,
    times, jsonutils, json,
  ]
import ./[entry]

let archivos =
  toSeq(walkDirRec("/home/carlosriaga/Pictures/pajareando", relative = false))

const meses = [
  "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto",
  "septiembre", "octubre", "noviembre", "diciembre",
]

proc sortByKey[A, B](x, y: (A, B)): int =
  system.cmp(x[0], y[0])

proc getExifDate(path: string): DateTime =
  try:
    let dateStr = execProcess(&"identify -format \"%[EXIF:DateTime]\" '{path}'").strip()
    result = dateStr.parse("yyyy:MM:dd hh:mm:ss")
  except TimeParseError:
    echo &"{path} has an invalid date", getCurrentExceptionMsg()
    result = local(getFileInfo(path).creationTime)

proc extraeLugares(nombrecarpeta: string): string = #seq[string] =
  for c in nombrecarpeta:
    if not c.isDigit:
      result.add(c)
    else:
      continue
  result = toLower(result).multiReplace(
      [("á", "a"), ("é", "e"), ("í", "i"), ("ó", "o"), ("ú", "u")]
    )

  for mes in meses:
    result = result.replace(mes, "")

  if result == "":
    echo "aca paso algo"
  #if strip(lugarSinNumeros) notin lugares:
  #  lugares.add(strip(lugarSinNumeros))

proc limpiaNombreAve(name: string): tuple[continua: bool, name: string] =
  # Borra los archhivos que empiezan con DSC y F_lzn y elimina numeros en el nombre del ave
  if name.startsWith("DSC") or name.startsWith("f_lzn"):
    result.continua = true
  for caracter in name:
    if caracter.isDigit:
      discard
    else:
      result.name.add(caracter)
  let nombreSplited = strip(result.name).split
  if len(nombreSplited) < 2:
    result.name = nombreSplited[0]
  else:
    result.name = nombreSplited[0] & " " & nombreSplited[1]

proc creaListaNombreAve(
    nombreAve: string, listaNombresAves: var OrderedTable[int, string]
): int =
  var encontrado = false
  for id, name in listaNombresAves:
    #echo "nombre ave  ******    ", (nombreAve: nombreAve, name: name)
    if name == nombreAve:
      encontrado = true
      result = id
      #echo "ya existe....  ", (nombreAve: nombreAve, id: id)
  if not encontrado:
    result = len(listaNombresAves)
    listaNombresAves[len(listaNombresAves)] = nombreAve

    #echo "no existe....  ", (nombreAve: nombreAve, id: len(listaNombresAves))

proc creaBaseAves(): seq[Entry] =
  let archivos =
    toSeq(walkDirRec("/home/carlosriaga/Pictures/pajareando", relative = false))
  var listaNombresAves: OrderedTable[int, string]
  for path in archivos:
    var (dir, name, ext) = splitFile path
    if ext != ".jpg":
      continue

    let tail = strip(splitPath(dir).tail)
    #var noNumberName = ""
    let date = getExifDate(path)
    let lugar = extraeLugares(tail)
    if lugar == "":
      echo (path: path)

    let (continua, nombreAve) = limpiaNombreAve(name)
    if continua:
      continue
    else:
      name = nombreAve

    # añade el nombre del ave y un id a la lista 
    var id = creaListaNombreAve(name, listaNombresAves)

    result.add(Entry(id: id, name: name, lugar: lugar, date: date, path: path))

proc toJsonHook*(a: DateTime): JsonNode =
  newJString(a.format(entryDateFormat))

let datosPath = "datos.json"
if not fileExists(datosPath):
  let datos = creaBaseAves()
  writeFile(datosPath, $toJson(datos))
