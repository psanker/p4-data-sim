read_zipped_dta <- function(path) {
  stopifnot(is.character(path))
  stopifnot(length(path) == 1)
  stopifnot(grepl("\\.dta\\.zip$", path))

  tmpdir <- tempdir()

  filename <- gsub("\\.zip$", "", basename(path))
  tmp_file_path <- file.path(tmpdir, filename)

  unzip(path, exdir = tmpdir)
  on.exit(unlink(tmp_file_path))

  haven::read_dta(tmp_file_path)
}
