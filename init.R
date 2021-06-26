my_packages = c("leaflet", "readr","rjson","ggplot2")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))
install.packages("/app/rgdal_1.5-10.tar.gz", repos=NULL, type="source")
