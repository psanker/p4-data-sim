library(targets)
library(tarchetypes)
library(crew)

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

tar_option_set(
  controller = crew_controller_local(workers = 2)
)

# Add tar_targets() to this list to define the pipeline
rlang::list2(
  # ---- 0. Load data ----
  tar_file(
    raw_p4c6_file,
    datalad_raw_path("panel4_c6-nightly.dta.zip"),
  ),
  tar_target(
    raw_p4c6,
    read_zipped_dta(raw_p4c6_file)
  ),
  tar_file(
    raw_p4c7_file,
    datalad_raw_path("panel4_c7-nightly.dta.zip"),
  ),
  tar_target(
    raw_p4c7,
    read_zipped_dta(raw_p4c7_file)
  ),
  # ---- 1. Transform data ----
  tar_target(
    prepped_p4c6,
    raw_p4c6 |>
      tidytable::select(
        cint1, cint2, cint4, cint11,
        cint19, cint21, cint22, cint23,
        cint24, cint27, cint28, cint29,
        cint30,
        cfemale = ccfemale,
        ajobloss = acov2_2,
        ccohort = cohort,
      ) |>
      tidytable::mutate(cycle = 6L)
  ),
  tar_target(
    prepped_p4c7,
    raw_p4c7 |>
      tidytable::select(
        cint1, cint2, cint4, cint11,
        cint19, cint21, cint22, cint23,
        cint24, cint27, cint28, cint29,
        cint30,
        cfemale = ccfemale,
        ajobloss = acov2_2,
        ccohort = cohort,
      ) |>
      tidytable::mutate(cycle = 7L)
  ),
  tar_target(
    prepped_c6c7,
    {
      out <- tidytable::bind_rows(prepped_p4c6, prepped_p4c7) |>
        haven::zap_labels() |>
        tidytable::mutate(
          ccohort = tidytable::case_when(
            ccohort %in% c(7, 9) ~ 0, # Urban
            ccohort %in% c(8, 10) ~ 1, # Rural
            TRUE ~ ccohort,
          ),
        )

      # Complete case analysis, although maybe I should keep
      # rows with at least some demographics
      out[complete.cases(out)]
    }
  ),
  tar_target(
    jittered_c6c7,
    prepped_c6c7 |>
      jitter_outcomes(.cols = tidyselect::starts_with("cint"), .threshold = 0.1)
  ),

  # ---- 2. Modeling ----
  tar_target(
    inp_kfa,
    list(prepped_c6c7, jittered_c6c7)
  ),
  tar_target(inp_kfa_names, c("nojitter", "jitter")),
  tar_target(
    kfa_mod,
    evaluate_kfa(inp_kfa),
    pattern = map(inp_kfa)
  ),

  # ---- 3. Exports ----
  tar_file(
    jittered_c6c7_out,
    {
      path <- datalad_exports_path("p4-data-sim", "jittered.csv")
      data.table::fwrite(jittered_c6c7, path)
      path
    }
  ),

  # ---- N. Reporting ----
  tar_render(
    simulation_report,
    here::here("outputs/sim-report.Rmd")
  ),
  tar_file(
    kfa_report,
    kfa::kfa_report(
      kfa_mod,
      file.path("outputs", paste0(inp_kfa_names, ".html"))
    ),
    pattern = map(kfa_mod, inp_kfa_names)
  )
)
