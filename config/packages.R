# Capture soft dependencies
languageserver::run

# Attach packages here for interactive work
NULL

# Tell targets to attach these packages before running each target
targets::tar_option_set(
  packages = NULL
)
