# Go to specific step
mathboxGo = (iframe, step) ->
  return unless iframe.contentWindow
  iframe.contentWindow.postMessage { mbgo: step }, '*'

# Set speed
mathboxSpeed = (iframe, speed) ->
  return unless iframe.contentWindow
  iframe.contentWindow.postMessage { mbspeed: speed }, '*'


slomo = (e) ->
  $('body')[if e.shiftKey then 'addClass' else 'removeClass']('slomo')
  speed = if e.shiftKey then .2 else 1
  return unless slides.$visibleIframes
  slides.$visibleIframes.each -> mathboxSpeed(@, speed)


changeSlide = (e, from, to) ->
  $subslide = $.deck('getSlide', to)
  $parents = $subslide.parents('.slide')
  $topslide = if $parents.length then $parents else $subslide

  step = $topslide.find('.slide').index($subslide) + 2

  # Sync up iframe mathboxes to correct step
  slides.$visibleIframes.each -> mathboxGo(@, step)

  # Pre-load iframes (but allow time for current transition)
  whichEnd = if to > from then 1 else -1
  slides.$iframeIndex[to].forEach (iframe) ->
    setTimeout (->
      iframe.onload = ->
        iframe.onload = null
        mathboxGo(iframe, step)
    ), slides.transition


$ ->
  $(document).keydown(slomo).keyup(slomo)
  $(document).bind 'deck.change', changeSlide
