.onLoad <- function(libname, pkgname) {
    cachedir <- file.path(Sys.getenv("HOME"), ".dbinterface")
    Sys.setenv("dbinterface-cachedir" = cachedir)

    if (!dir.exists(cachedir)) dir.create(cachedir)
}

.onUnload <- function(libname, pkgname) {
    Sys.unsetenv("dbinterface-cachedir")
}