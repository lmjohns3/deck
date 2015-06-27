# Code for pre-loading and post-unloading iframes. Most of this is taken from
# Steven Wittens (@unconed): https://github.com/unconed/fullfrontal, but I've
# tried to separate out the iframe handling from interactions with mathbox,
# since it's nice to have videos auto-load even if you're not using math.

TRANSITION = 300
$IFRAME_INDEX = {}


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
  $subslide = $.deck('getSlide', to)
  $parents = $subslide.parents('.slide')
  $slide = if $parents.length then $parents else $subslide

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
  ), TRANSITION

  # Preload nearby iframes.
  $IFRAME_INDEX[to].forEach (iframe) ->
    setTimeout (-> enableIframe(iframe)), TRANSITION

  # Unload non-nearby iframes.
  $('iframe').not($IFRAME_INDEX[to]).each ->
    iframe = @
    setTimeout (-> disableIframe(iframe)), TRANSITION


$ ->
  # Build index of which iframes are active per slide
  $('.slide').each (i) ->
    $this = $(@)
    $parents = $this.parents('.slide')
    $this = $parents if $parents.length
    [i-1, i, i+1].forEach (i) ->
      $IFRAME_INDEX[i] or= []
      $this.find('iframe').each -> $IFRAME_INDEX[i].push @

  # Disable all iframes at first.
  $('iframe').each -> disableIframe(@)

  $(document).bind 'deck.change', changeSlide
