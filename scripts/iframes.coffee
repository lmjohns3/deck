# Code for pre-loading and post-unloading iframes. Most of this is taken from
# Steven Wittens (@unconed): https://github.com/unconed/fullfrontal, but I've
# separated out the iframe handling from interactions with mathbox, using some
# really kludgy global variables.

window.slides or= {}
window.slides.transition or= 500
window.slides.$visibleIframes = null
window.slides.$iframeIndex = {}


disableIframe = (iframe) ->
  return if $(iframe).data('src')
  src = $(iframe).attr('src')
  $(iframe).data('src', src)
  iframe.onload = null
  iframe.src = 'about:blank'


enableIframe = (iframe) ->
  src = $(iframe).data('src')
  return unless src
  iframe.src = src
  $(iframe).data('src', null)


changeSlide = (e, from, to) ->
  getTopSlide = (step) ->
    $slide = $.deck('getSlide', step)
    $parents = $slide.parents('.slide')
    if $parents.length then $parents else $slide

  $slide = getTopSlide(to)
  slides.$visibleIframes = $slide.find('iframe')

  # Start playing videos in our new slide.
  $slide.find('video').each -> @play()
  $slide.find('iframe').each ->
    return unless $(@).hasClass('autoplay')
    return unless /youtube\.com/.test $(@).attr('src')
    @contentWindow.postMessage '{"event":"command","func":"playVideo","args":""}', '*'

  # Stop videos in slide that we came from.
  setTimeout (->
    $.deck('getSlide', from).find('video').each -> @pause()
    $.deck('getSlide', from).find('iframe').each ->
      return unless /youtube\.com/.test $(@).attr('src')
      @contentWindow.postMessage '{"event":"command","func":"pauseVideo","args":""}', '*'
  ), slides.transition / 2

  # Preload nearby iframes.
  slides.$iframeIndex[to].forEach (iframe) ->
    setTimeout (-> enableIframe(iframe)), slides.transition / 2

  # Unload non-nearby iframes.
  $('iframe').not(slides.$iframeIndex[to]).each ->
    iframe = @
    setTimeout (-> disableIframe(iframe)), slides.transition / 2


$ ->
  # Build index of which iframes are active per slide
  $('.slide').each (i) ->
    $this = $(@)
    $parents = $this.parents('.slide')
    $this = $parents if $parents.length
    $iframes = $this.find('iframe')
    [i-1, i, i+1].forEach (i) ->
      slides.$iframeIndex[i] or= []
      $iframes.each -> slides.$iframeIndex[i].push @

  # Disable all iframes at first.
  $('iframe').each -> disableIframe(@)

  $(document).bind 'deck.change', changeSlide
