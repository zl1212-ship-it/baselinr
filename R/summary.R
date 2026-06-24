#' Overall WWC baseline-equivalence verdict
#'
#' Summarizes a [baseline_equivalence()] table into a one-row overall
#' assessment: how many covariates fall in each What Works Clearinghouse (WWC)
#' category, the largest absolute effect size, and an overall verdict.
#'
#' The overall verdict follows the logic of the categories: if any covariate is
#' `"not_satisfied"`, baseline equivalence cannot be established
#' (`"not_satisfied"`); otherwise, if any covariate requires adjustment, the
#' verdict is `"satisfied_with_adjustment"` (equivalence holds only if those
#' covariates are adjusted for in the impact model); otherwise `"satisfied"`.
#'
#' @param equivalence A data frame returned by [baseline_equivalence()].
#'
#' @return A one-row data frame with columns `n_covariates`, `n_satisfied`,
#'   `n_satisfied_with_adjustment`, `n_not_satisfied`, `max_abs_effect`, and
#'   `overall`.
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' df <- data.frame(
#'   treat = c(1, 1, 1, 0, 0, 0),
#'   pretest = c(5, 6, 7, 4, 5, 6),
#'   female = c(1, 0, 1, 0, 0, 1)
#' )
#' wwc_summary(baseline_equivalence(df, "treat"))
#'
#' @export
wwc_summary <- function(equivalence) {
  required <- c("covariate", "effect_size", "wwc_category")
  if (!is.data.frame(equivalence) || !all(required %in% names(equivalence))) {
    stop("`equivalence` must be a data frame from `baseline_equivalence()`.",
      call. = FALSE
    )
  }
  cat <- equivalence$wwc_category
  n_not <- sum(cat == "not_satisfied", na.rm = TRUE)
  n_adj <- sum(cat == "satisfied_with_adjustment", na.rm = TRUE)
  n_sat <- sum(cat == "satisfied", na.rm = TRUE)
  overall <- if (n_not > 0L) {
    "not_satisfied"
  } else if (n_adj > 0L) {
    "satisfied_with_adjustment"
  } else {
    "satisfied"
  }
  data.frame(
    n_covariates = nrow(equivalence),
    n_satisfied = n_sat,
    n_satisfied_with_adjustment = n_adj,
    n_not_satisfied = n_not,
    max_abs_effect = max(abs(equivalence$effect_size), na.rm = TRUE),
    overall = overall,
    stringsAsFactors = FALSE
  )
}

#' Overall and differential attrition
#'
#' Computes overall and differential sample attrition for a two-group design,
#' the inputs to the What Works Clearinghouse (WWC) attrition standard.
#' Differential attrition is the absolute difference between the treatment and
#' comparison attrition rates.
#'
#' This function reports the attrition rates; it does not classify them. Compare
#' the overall and differential rates against the WWC attrition boundary for
#' your chosen response assumption (cautious or optimistic) in the Procedures
#' Handbook.
#'
#' @param treatment Vector identifying group membership; exactly two unique
#'   non-missing values (the larger is treated as the treatment group, as in
#'   [hedges_g()]).
#' @param retained Logical (or `0/1`) the same length as `treatment`: `TRUE`/`1`
#'   for cases retained in the analytic sample, `FALSE`/`0` for those lost.
#' @param na.rm Logical; drop rows where `treatment` or `retained` is `NA`.
#'   Default `TRUE`.
#'
#' @return A one-row data frame with columns `attrition_overall`,
#'   `attrition_treatment`, `attrition_comparison`, and
#'   `differential_attrition` (all proportions).
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' set.seed(1)
#' g <- rep(c(1, 0), each = 100)
#' kept <- rbinom(200, 1, ifelse(g == 1, 0.9, 0.8))
#' attrition(g, kept)
#'
#' @export
attrition <- function(treatment, retained, na.rm = TRUE) {
  if (length(treatment) != length(retained)) {
    stop("`treatment` and `retained` must have the same length.", call. = FALSE)
  }
  if (isTRUE(na.rm)) {
    keep <- !is.na(treatment) & !is.na(retained)
    treatment <- treatment[keep]
    retained <- retained[keep]
  }
  if (is.numeric(retained) && !all(retained %in% c(0, 1))) {
    stop("`retained` must be logical or coded 0/1.", call. = FALSE)
  }
  retained <- as.logical(retained)
  levs <- sort(unique(treatment))
  if (length(levs) != 2L) {
    stop("`treatment` must have exactly two unique non-missing values.",
      call. = FALSE
    )
  }
  a_c <- 1 - mean(retained[treatment == levs[1]])
  a_t <- 1 - mean(retained[treatment == levs[2]])
  data.frame(
    attrition_overall = 1 - mean(retained),
    attrition_treatment = a_t,
    attrition_comparison = a_c,
    differential_attrition = abs(a_t - a_c),
    stringsAsFactors = FALSE
  )
}
