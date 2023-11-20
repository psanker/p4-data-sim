prior_predictive_simulation <- function(n) {
  rethinking::dordlogit()
}

jitter_outcomes <- function(dat,
                            .cols = tidyselect::everything(),
                            .threshold = 0.2) {
  expr <- rlang::enquo(.cols)
  pos <- tidyselect::eval_select(expr, data = dat)

  dat |>
    tidytable::mutate(
      tidytable::across(
        .cols = tidyselect::all_of(pos),
        .fns = \(x) {
          pr_k <- table(x) / length(x)
          cum_pr_k <- cumsum(pr_k)
          log_co <- qlogis(cum_pr_k)

          resamp <- rethinking::rordlogit(length(x), a = log_co) - 1
          n_replace <- floor(length(x) * .threshold)
          rows <- sample(seq_along(x), n_replace)

          x[rows] <- resamp[rows]
          x
        }
      )
    )
}

evaluate_kfa <- function(dat, ...) {
  dat <- tidytable::select(dat, tidyselect::starts_with("cint"))

  kfa::kfa(dat, ...)
}
