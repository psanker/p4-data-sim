stop0 <- function(...) {
  stop(..., call. = FALSE)
}

`%if_empty_string%` <- function(x, y) {
  stopifnot(length(x) == 1)
  
  if (identical(x, "")) y else x
}

run_unit_tests <- function(path = here::here("tests")) {
  if (dir.exists(path)) {
    num_files <- length(list.files(path, pattern = "^test-.*\\.R"))
    
    if (num_files > 0) {
      testthat::test_dir(path)
    } else {
      message("No unit tests found in 'tests' folder")
    }
  }
}
