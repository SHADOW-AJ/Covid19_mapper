my_packages = c("leaflet", "readr","rjson","ggplot2")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))
install.packages("/app/localpkgs/Rnlminb2_2110.79.tar.gz", repos=NULL, type="source")
