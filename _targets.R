src_files <- list.files(
  here::here("R"),
  pattern = "\\.[rR]$",
  full.names = TRUE
)

for (f in src_files) {
  source(f)
}

# Edit 'config/packages.R' to attach packages needed for your pipeline
# NB: If you use renv, add `package::function` references to enable
#     renv to track "Suggested" packages, which are not always picked
#     up with `renv::snapshot()`
source(here::here("config/packages.R"))

# Edit 'config/environment.R' to define globals from environment vars
source(here::here("config/environment.R"))



# Run tests if configured
if (isTRUE(F_RUN_TESTS)) {
  library(testthat)

  run_unit_tests()
}

# Add tar_targets() to this list to define the pipeline
list(
  tar_blueprints()
)
