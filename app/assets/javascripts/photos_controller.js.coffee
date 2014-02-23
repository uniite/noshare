class @PhotosController

  launchFullscreen: (element) ->
    console.log("Launching fullscreen")
    if element.requestFullscreen
      element.requestFullscreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.webkitRequestFullscreen
      element.webkitRequestFullscreen()
    else if element.msRequestFullscreen
      element.msRequestFullscreen()


  constructor: () ->
    @indexTemplate = doT.template($("#photosTemplate").html())
    @showYearTemplate = doT.template($("#photosZoomTemplate").html());
    @showDetailTemplate = doT.template($("#photoDetailTemplate").html());
    #$(".view").hide();

  index: () ->
    db.info (err, info) =>
      if info.doc_count > 0
        @displayIndex()
      else
        $.get "/photos.json", (response) =>
            for photo in response
              photo._id = "#{photo.id}"
              db.put(photo, (err, response) -> console.error(err))
            @displayIndex()

  displayIndex: () ->
    thumbsByYear = (doc, emit) ->
      emit(moment.unix(doc.taken_at).format("YYYY"), doc)
    db.query {map: thumbsByYear}, {reduce: false}, (err,response) =>
      if err
        console.error(err)
        alert("Error!")
        return
      #@allPhotos = _.values
      @photosByYear = _.groupBy(response.rows, "key")
      keys = _.keys(@photosByYear).sort().reverse()
      console.log(@photosByYear)
      $view = $("#home")
      @render $view, @indexTemplate({keys: keys, photos: @photosByYear}),
        transition: false,
        callback: () ->
          #$("img.lazy").lazyload()
          $(".row").hammer().on "touch", (event) ->
            $(this).addClass("touched")
          $(".row").hammer().on "release", (event) ->
            $(this).removeClass("touched")
          $(".row").hammer().on "tap", (event) ->
            period = $(this).data("period")
            window.router.go("/app/photos/years/#{period}")

  showYear: (year) ->
    thumbsForYear = (doc, emit) ->
      if moment.unix(doc.taken_at).format("YYYY") == year
        emit(doc._id, doc)
    do () => #db.query {map: thumbsForYear}, {reduce: false}, (err,response) =>
#      if err
#        console.error(err)
#        alert("Error!")
#        return
      console.log("show year #{year}")
      photos = @photosByYear[year]
      $view = $("#photosZoom");
      @render $view, @showYearTemplate({period: year, photos: photos}),
        transition: true
        callback: () ->
          $(".photo-medium").hammer().on "tap", (event) ->
            id = $(this).data("id")
            window.router.go("/app/photos/#{id}")

  showDetail: (id) ->
    db.get id, (err, photo) =>
      if err
        console.error(err)
        alert("Error!")
        return
      console.log(photo)
      $view = $("#photoDetail");
      @render $view, @showDetailTemplate(photo),
        transition: true
        callback: () =>
          $(".photo").hammer().on "tap", (event) =>
            @launchFullscreen($(this)[0])

  render: ($view, html, options) ->
    $view.addClass("current-view")
    $view[0].innerHTML = html
    $view[0].offsetHeight
    if options?.transition
      $view.addClass("main-view")
    # Call the callback if we were given one
    options.callback?()
