#' Build path in the data folder
#'
#' @param ... Path elements to be passed to here::here
#' @param .proj The current working project. Defaults to
#'   the TAR_PROJECT env var
#' @return The full absolute path
datalad_path <- function(...) {
  here::here("data", ...)
}

#' Build path in the data/raw folder
#'
#' @param ... Path elements to be passsed to datalad_proj_path()
#' @return The full absolute path
datalad_raw_path <- function(...) {
  datalad_path("raw", ...)
}

#' Build path in the data/exports folder
#'
#' @param ... Path elements to be passsed to datalad_proj_path()
#' @return The full absolute path
datalad_exports_path <- function(...) {
  datalad_path("exports", ...)
}

#' Build path in the data/nightly/[latest|snapshots] folder
#'
#' @param ... Path elements to be passsed to datalad_proj_path()
#' @param .root Make the path directly from nightly and not from
#'   the latest or snapshots subdirs
#' @param .latest Use latest or snapshots subdirs
#' @return The full absolute path
datalad_nightly_path <- function(..., .root = FALSE, .latest = TRUE) {
  versionify_path(
    datalad_path("nightly"),
    .root = .root, .latest = .latest, ...
  )
}

versionify_path <- function(prefix, .root, .latest, ...) {
  if (!isTRUE(.root)) {
    prefix <- file.path(
      prefix,
      if (isTRUE(.latest)) "latest" else "snapshots"
    )
  }

  file.path(prefix, ...)
}
