TRANSITION = 300
$IFRAME_INDEX = {}
$visibleIframes = null


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
  return unless $visibleIframes
  $visibleIframes.each -> mathboxSpeed(@, speed)


changeSlide = (e, from, to) ->
  $subslide = $.deck('getSlide', to)
  $parents = $subslide.parents('.slide')
  $slide = if $parents.length then $parents else $subslide

  $visibleIframes = $slide.find('iframe')

  # Sync up iframe mathboxes to correct step
  step = $slide.find('.slide').index($subslide) + 2
  $visibleIframes.each -> mathboxGo(@, step)

  # Pre-load iframes (but allow time for current transition)
  whichEnd = if to > from then 1 else -1
  $IFRAME_INDEX[to].forEach (iframe) ->
    setTimeout (->
      iframe.onload = ->
        iframe.onload = null
        mathboxGo(iframe, step)
    ), TRANSITION


$ ->
  # Build index of which iframes are active per slide
  $('.slide').each (i) ->
    $this = $(@)
    $parents = $this.parents('.slide')
    $this = $parents if $parents.length
    [i-1, i, i+1].forEach (i) ->
      $IFRAME_INDEX[i] or= []
      $this.find('iframe').each -> $IFRAME_INDEX[i].push @

  $(document).keydown(slomo).keyup(slomo)
  $(document).bind 'deck.change', changeSlide
