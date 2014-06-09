window.Cache = (function() {
  function Cache() {}

  Cache.prototype.initialize = function() {
    //var filer = new Filer();
    var size;
    window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
    size = 5 * 1024 * 1024;
    x = (function(_this) {
      return function() {
        return _this.foo;
      };
    })(this);
    var self = this;
    return new Promise(function(resolve, reject) {
      window.requestFileSystem(window.PERSISTENT, size,
        function(fs) {
          self.initFS(fs);
          resolve();
        },
        function(e) {
          self.errorHandler(e)
          reject(e);
        }
      );
    });
  };

  Cache.prototype.initFS = function(fs) {
    this.fs = fs;
    console.log("Got FS");
    console.log(fs);
  };

  Cache.prototype.errorHandler = function(e) {
    var msg;
    switch (e.code) {
      case FileError.QUOTA_EXCEEDED_ERR:
        msg = 'QUOTA_EXCEEDED_ERR';
        break;
      case FileError.NOT_FOUND_ERR:
        msg = 'NOT_FOUND_ERR';
        break;
      case FileError.SECURITY_ERR:
        msg = 'SECURITY_ERR';
        break;
      case FileError.INVALID_MODIFICATION_ERR:
        msg = 'INVALID_MODIFICATION_ERR';
        break;
      case FileError.INVALID_STATE_ERR:
        msg = 'INVALID_STATE_ERR';
        break;
      default:
        msg = 'Unknown Error';
    }
    return console.error("Cache error: " + msg);
  };

  Cache.prototype.get = function(key) {
    return null;
  };

  Cache.prototype.set = function(key, val) {};

  return Cache;

})();
