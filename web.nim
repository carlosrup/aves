# NOTE: to allow ./index.html to load a local file in firefox 106+, set security.fileuri.strict_origin_policy to false in about:config
import std/[dom, jsconsole, times, jsfetch, asyncjs, json, jsonutils]
import karax/[karax, karaxdsl, vdom]
import ./[entry]

# voy a arregla error async, separando asincrono de la funcion createApp
# creando el objeto state para guardar si ya se leyeron los datos
# ARREGLAR PARSEHOOK
type
  State = object
    fetchState*: FetchState
    data*: seq[Entry]

  FetchState = enum
    unstarted
    success
    failure
    fetching

const homeDir = "/home/cristobal"
# const homeDir = "/home/carlosriaga/"
const datosPath = homeDir & "/clones/aves/datos.json"
# const datosPath = homeDir & "Documents/nim/fotos%20aves/datos.json"
var state = State()

proc fromJsonHook*(a: var DateTime, b: JsonNode) =
  assert not b.isNil
  assert b.kind == JString
  a = parse(b.getStr, entryDateFormat)

proc fetchData(state: var State) {.async.} =
  state.fetchState = fetching
  let response = await fetch datosPath.cstring

  if response.ok:
    state.data = parseJson($response.body).jsonTo(seq[Entry])
    state.fetchState = success
  else:
    state.fetchState = failure
  redraw()

proc redraw() =
  if not kxi.surpressRedraws:
    redraw(kxi)

proc createApp(): VNode =
  if state.fetchState == unstarted:
    discard fetchData(state)

  buildHtml:
    case state.fetchState
    of unstarted:
      tdiv:
        text " unstarted"
    of failure:
      tdiv:
        text " failure"
    of fetching:
      tdiv:
        text " fetching"
    of success:
      tdiv:
        for ave in state.data:
          tdiv:
            h1:
              text "ave.name"

    # button:
    #   text "Haz clic"
    #   proc onclick() =
    #     window.alert("¡Funciona!")

setRenderer createApp
