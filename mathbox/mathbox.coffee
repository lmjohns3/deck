# Code for loading a mathbox. Mostly take from Steven Wittens (@unconed):
# https://github.com/unconed/fullfrontal

clocks = {}  # Object for storing unique clocks.
ticker = 0   # Global time variable. Updated by animation frame request.
target = 1   # Variables that control rendering speed.
speed = 1

# Rendering callback. This updates the speed and ticker state.
render = ->
  temp = 1
  window.requestAnimationFrame(render)
  if mb.mathbox
    # smooth out transition
    temp = temp + (target - temp) * .3
    speed = speed + (temp - speed) * .3
    # apply speed
    mb.mathbox.speed(speed)
    # update clock
    ticker += (1000 / 60) * speed


# Global hash for storing mathbox entities.
window.mb =
  setup: ->
  options: {}
  script: []

  mathbox: null
  director: null

  clock: (id) ->
    clocks[id] = ticker unless clocks[id]
    (ticker - clocks[id]) * 0.001


# Callback for loading THREE.js; sets up mathbox.
loadThree = ->
  opts =
    cameraControls: true
    stats: false
    scale: 1
    orbit: 3.5
    theta: 0
  opts[k] = v for k, v in mb.options or {}
  mb.mathbox = mathBox(opts).start()
  mb.mathbox.transition(300)
  mb.director = new MathBox.Director(mb.mathbox, mb.script or [])
  mb.setup(mb.mathbox, mb.director) if mb.setup

  # stand-alone controls.
  window.addEventListener 'keydown', (e) ->
    mb.director.back() if e.keyCode == 38 or e.keyCode == 37
    mb.director.forward() if e.keyCode == 40 or e.keyCode == 39

  # receive navigation commands from parent frame.
  window.addEventListener 'message', (e) ->
    mb.director.go.apply(mb.director, [e.data.mbgo]) if e.data.mbgo
    target = e.data.mbspeed if e.data.mbspeed


$ ->
  window.requestAnimationFrame(render)

  url = location.hash
  match = url.match(/^#(.+)$/)
  preload = [
    '../local/mathbox.js/shaders/snippets.glsl.html'
    '../local/threertt.js/build/ThreeRTT.glsl.html'
    '../local/threertt.js/shaders/examples.glsl.html'
  ]
  preload.push('mb-' + match[1] + '.html') if match
  ThreeBox.preload preload, loadThree, false
