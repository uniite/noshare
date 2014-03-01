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
    @revisionKey = "photosRevision";
    #$(".view").hide();

  syncDB: (since, callback) ->
    url = "#{window.noshareHost}/photos.json"
    if since
      url += "?since=#{since}"
    console.log("Syncing from #{url}")
    $.get(url, (response) =>
      console.log(response)
      localStorage.setItem(@revisionKey, response.revision)
      docs = []
      # Any updated photos to process?
      updated = response.photos.updated
      if updated.length > 0
        for p in updated
          p._id = "#{p.id}"
        docs = docs.concat(updated)
      # Do we have any deleted photos to process?
      deleted = response.photos.deleted
      if deleted.length > 0
        deleted_docs = deleted.map (id) ->
          _id: "#{id}"
          _deleted: true
        docs = docs.concat(deleted_docs)
      # Need to update the DB
      console.log(docs)
      if docs.length > 0
        db.bulkDocs {docs: docs}, (err, response) ->
          if err
            console.error(err)
          else
            callback()
      # No DB changes neccesary
      else
        callback()
    ).fail( () ->
      console.error("Failed to load #{url}. Continuing with cached Photos.")
      callback()
    )

  index: () ->
    @showLoading($("#home"))
    since = localStorage.getItem(@revisionKey)
    if since
      console.log("Starting from #{since}")
      @syncDB since, () =>
        @displayIndex()
    else
      console.log("Starting from scratch")
      @syncDB null, () =>
        @displayIndex()

  displayIndex: () ->
    thumbsByYear = (doc, emit) ->
      emit(moment.unix(doc.taken_at).format("YYYY"), doc)
    #db.query {map: thumbsByYear}, {reduce: false}, (err,response) =>
    db.allDocs {include_docs: true}, (err,response) =>
      console.log(response)
      if err
        console.error(err)
        alert("Error!")
        return
      @allPhotos = response.rows.map (p) -> p.doc
      @photosByYear = _.groupBy(@allPhotos, "year")
      keys = _.keys(@photosByYear).sort().reverse()
      console.warn(@photosByYear)
      $view = $("#home")
      html = @indexTemplate({keys: keys, photos: @photosByYear})
      console.log('Rendering')
      @render $view, html,
        transition: false,
        callback: () =>
          queue = []
          for photo_div in $("#home .photo-section")
            console.log("queue #{$(photo_div).data("year")}")
            do (photo_div) =>
              queue.push () =>
                console.log("render #{$(photo_div).data("year")}")
                for photo in @photosByYear[$(photo_div).data("year")]
                  img = document.createElement("img")
                  img.className = "photo-thumb"
                  img.src = photo.thumb_data
                  photo_div.appendChild(img)

          processor = () ->
            renderFunc = queue.shift()
            if renderFunc
              renderFunc()
              setTimeout(processor, 10)
            else
              #$("img.lazy").lazyload()
              #$(".row").hammer().on "touch", (event) ->
              #  $(this).addClass("touched")
              #$(".row").hammer().on "release", (event) ->
              #  $(this).removeClass("touched")
              $(".row").hammer().on "tap", (event) ->
                period = $(this).data("period")
                window.router.go("/app/photos/years/#{period}")

          window.setTimeout(processor, 0)

  showYear: (year) ->
    #thumbsForYear = (doc, emit) ->
    #  if moment.unix(doc.taken_at).format("YYYY") == year
    #    emit(doc._id, doc)
    do () => #db.query {map: thumbsForYear}, {reduce: false}, (err,response) =>
#      if err
#        console.error(err)
#        alert("Error!")
#        return
      console.log("show year #{year}")
      photos = @photosByYear[year]
      $view = $("#photosZoom");
      console.log(photos)
      @render $view, @showYearTemplate({host: noshareHost, period: year, photos: photos}),
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
      @render $view, @showDetailTemplate({photo: photo, host: noshareHost}),
        transition: true
        callback: () =>
          $(".photo").hammer().on "tap", (event) =>
            @launchFullscreen($(this)[0])


  showLoading: ($view) ->
    $view[0].innerHTML = "<div class='container'>" +
      "<h3 class='text-center'><span class='glyphicon glyphicon-refresh spin'></span></h3>" +
    "</div>"

  render: ($view, html, options) ->
    $view.addClass("current-view")
    $view[0].innerHTML = html
    $view[0].offsetHeight
    $view.scrollTop(0)
    if options?.transition
      $view.addClass("main-view")
    # Call the callback if we were given one
    options.callback?()
