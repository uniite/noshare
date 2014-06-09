class @Database

  open: (success, error) ->
    size = 5 * 1024 * 1024  # 5MB
    @db = openDatabase("noshare", "", "noshare local cache", size)
    console.info("Opening databse. Version: #{JSON.stringify(@db.version)}")
    if @db.version == ""
      @db.changeVersion("", "1", @setupDB, success, error)

  setupDB: (tx) ->
    createTableSql = "
      CREATE TABLE photos(
        id          INT PRIMARY KEY NOT NULL,
        taken_at    INT,
        thumb_data  TEXT,
        url         TEXT,
      )"
    console.log("Executing CREATE TABLE")
    tx.executeSql(createTableSql, [])


  addPhoto: (photo, callback) ->
    @db.transaction (tx) ->
      tx.executeSql(
        "INSERT INTO photos(id, taken_at, thumb_data, url) VALUES (?, ?, ?, ?)",
        [photo.id, photo.taken_at, photo.thumb_data, photo.url]
      )
      calllback()

