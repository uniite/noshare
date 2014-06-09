#class @Cache
#
#  constructor:
#    @filer = new Filer()
#    @filter.init { persistent: false, size: 1024 * 1024 }, (fs) =>
#      @fs = fs
#  // filer.size == Filer.DEFAULT_FS_SIZE
#  // filer.isOpen == true
#  // filer.fs == fs
#    , onError
