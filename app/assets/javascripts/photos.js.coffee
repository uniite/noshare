# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Find the right method, call on correct element
launchFullscreen = (element) ->
  if element.requestFullscreen
    element.requestFullscreen()
  else if element.mozRequestFullScreen
    element.mozRequestFullScreen()
  else if element.webkitRequestFullscreen
    element.webkitRequestFullscreen()
  else if element.msRequestFullscreen
    element.msRequestFullscreen()

startViewfinder = (videoSource) ->
  viewfinder = $("#viewfinder")[0]
  if (!!window.stream)
    viewfinder.src = null
    window.stream.stop()

  successCallback = (stream) ->
    window.stream = stream  # make stream available to console
    viewfinder.src = window.URL.createObjectURL(stream)
    viewfinder.play()

  errorCallback = (error) ->
    console.log("navigator.getUserMedia error: ", error)

  constraints = {
    audio: false,
    video: {
      optional: [{sourceId: videoSource}]
    }
  }
  navigator.getUserMedia  = navigator.getUserMedia ||
                            navigator.webkitGetUserMedia ||
                            navigator.mozGetUserMedia ||
                            navigator.msGetUserMedia
  navigator.getUserMedia(constraints, successCallback, errorCallback)


storePhoto = (dataUri) ->
  $("#photoUploadPreview").attr("src", dataUri)
  $("#data_uri")[0].value = dataUri


readURI = (input) ->
  if input.files?[0]
    reader = new FileReader()
    reader.onload = (e) ->
      storePhoto(e.target.result)
    reader.readAsDataURL(input.files[0])

$(document).on "page:change", () ->
  if MediaStreamTrack and $("#photo_file").length > 0
    $ () ->
      $("#photo_file").change () ->
        readURI(this)
      $("#videoSource").change () ->
        startViewfinder($(this).val())
      return
      MediaStreamTrack.getSources (sources) ->
        i = 1
        for src in sources
          if src.kind == 'video'
            label = src.label || "Camera #{i}"
            $("#videoSource").append("<option value='#{src.id}'>#{label}</option>")
            i += 1
        startViewfinder()

  # Show the photo fullscreen when tapped/clicked
  $(".photo").click () ->
    launchFullscreen(this)

  fullScreenChanged = (enabled) ->
    console.log(enabled)
    if enabled?
      $(".photo").addClass("fullscreen")
    else
      $(".photo").removeClass("fullscreen")

  fullscreenEvents =
    "": "fullscreen"
    ms: "msFullscreenElement"
    moz: "mozFullScreen"
    webkit: "webkitIsFullScreen"

  for prefix, event of fullscreenEvents
    document.addEventListener "#{prefix}fullscreenchange", () ->
      fullScreenChanged(document[event])
