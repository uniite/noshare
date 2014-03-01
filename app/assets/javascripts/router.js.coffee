class @Router
  constructor: ->
    @historyStack = [];
    window.onpopstate = () =>
      console.log("State change!")
      @processStateChange()

  go: (path) =>
    @navgating = true
    #@navgating = true
    History.pushState(null, null, path)

  goBack: () =>
    previous = @historyStack.pop()
    console.log("Go Back to #{previous.viewID}")
    $newView = $("##{previous.viewID}")
    currentViewID = $(".current-view").attr("id")
    console.log("Clear #{currentViewID}")
    $currentView = $("##{currentViewID}")
    $newView.addClass("current-view")
    $currentView[0].offsetHeight
    $currentView.removeClass("main-view")
    transitionEnd = "webkitTransitionEnd msTransitionEnd transitionend"
    $currentView.one transitionEnd, () ->
      $currentView.removeClass("current-view")
      # Using one on its own wasn't working very well
      $(this).off(transitionEnd)

  processStateChange: () =>
    state = History.getState()
    path = state.hash
    lastState = @historyStack[-2..-2][0]
    stackState = @historyStack[-1..-1][0]
    console.log("Go #{path}")
    if path == lastState?.path
      @goBack()
    else if path != stackState?.path
      @loadRoute(path)
    @navigating = false;

  loadRoute: (path) ->
    console.log("Load route #{path}")
    currentViewID = $(".current-view").attr("id")
    @historyStack.push
      path: path
      viewID: currentViewID
    $(".current-view").removeClass("current-view")
    #hideView = () ->
    #  $("##{currentViewID}").hide()
    #setTimeout(hideView, 600)
    if path == "/app"
      window.photosController.index()
    else if m = path.match(/^\/app\/photos\/years\/(\d+)/)
      year = m[1]
      console.log(year)
      window.photosController.showYear(year)
    else if m = path.match(/^\/app\/photos\/(\d+)/)
      id = m[1]
      console.log(id)
      window.photosController.showDetail(id)

