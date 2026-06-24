#' baselinr: WWC-aligned baseline equivalence for education impact evaluations
#'
#' baselinr produces report-ready baseline equivalence tables for impact
#' evaluations in education research, following the conventions of the What
#' Works Clearinghouse (WWC). It does one thing: take a data frame, a
#' treatment indicator, and a set of continuous covariates, and report the
#' standardized mean difference (Hedges' g) and WWC equivalence category for
#' each covariate.
#'
#' @keywords internal
"_PACKAGE"

#' Hedges' g standardized mean difference
#'
#' Computes the standardized mean difference (Hedges' g) between a treatment
#' and a comparison group for a single numeric covariate, using the pooled
#' within-group standard deviation and the small-sample correction factor used
#' by the What Works Clearinghouse (WWC).
#'
#' The correction factor is \eqn{\omega = 1 - 3 / (4N - 9)}, where
#' \eqn{N = n_{treatment} + n_{comparison}}.
#'
#' @param x Numeric vector of covariate values.
#' @param treatment Vector the same length as `x` identifying group
#'   membership. Must have exactly two unique non-missing values. The larger
#'   value (e.g. `1`, `TRUE`, or the second sorted level) is treated as the
#'   treatment group; the other as the comparison group.
#' @param na.rm Logical; drop rows where `x` or `treatment` is `NA`.
#'   Default `TRUE`.
#'
#' @return A single numeric value: Hedges' g. Positive when the treatment
#'   group mean exceeds the comparison group mean.
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' x <- c(5, 6, 7, 4, 5, 6)
#' g <- c(1, 1, 1, 0, 0, 0)
#' hedges_g(x, g) # 0.8
#'
#' @importFrom stats var sd
#' @export
hedges_g <- function(x, treatment, na.rm = TRUE) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric.", call. = FALSE)
  }
  if (length(x) != length(treatment)) {
    stop("`x` and `treatment` must have the same length.", call. = FALSE)
  }
  if (isTRUE(na.rm)) {
    keep <- !is.na(x) & !is.na(treatment)
    x <- x[keep]
    treatment <- treatment[keep]
  }
  levs <- sort(unique(treatment))
  if (length(levs) != 2L) {
    stop("`treatment` must have exactly two unique non-missing values.",
      call. = FALSE
    )
  }
  comparison <- x[treatment == levs[1]]
  treated <- x[treatment == levs[2]]
  n_c <- length(comparison)
  n_t <- length(treated)
  if (n_c < 2L || n_t < 2L) {
    stop("Each group must have at least two observations.", call. = FALSE)
  }
  s_pooled <- sqrt(
    ((n_t - 1) * var(treated) + (n_c - 1) * var(comparison)) / (n_t + n_c - 2)
  )
  if (s_pooled == 0) {
    stop("Pooled standard deviation is zero; cannot standardize.",
      call. = FALSE
    )
  }
  d <- (mean(treated) - mean(comparison)) / s_pooled
  n_total <- n_t + n_c
  correction <- 1 - 3 / (4 * n_total - 9)
  d * correction
}

#' Classify baseline equivalence under WWC standards
#'
#' Maps standardized mean differences to the three What Works Clearinghouse
#' baseline-equivalence categories. Sign is ignored; classification uses the
#' absolute value of the effect size.
#'
#' @param es Numeric vector of standardized mean differences (e.g. values
#'   returned by [hedges_g()]).
#'
#' @return A character vector the same length as `es`:
#'   * `"satisfied"` when `|es| <= 0.05` (no adjustment needed),
#'   * `"satisfied_with_adjustment"` when `0.05 < |es| <= 0.25`
#'     (equivalence holds only if the covariate is adjusted for in the
#'     impact model),
#'   * `"not_satisfied"` when `|es| > 0.25`.
#'   `NA` inputs return `NA`.
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' wwc_classify(c(0.03, 0.12, 0.80))
#'
#' @export
wwc_classify <- function(es) {
  if (!is.numeric(es)) {
    stop("`es` must be numeric.", call. = FALSE)
  }
  a <- abs(es)
  out <- ifelse(
    a <= 0.05,
    "satisfied",
    ifelse(a <= 0.25, "satisfied_with_adjustment", "not_satisfied")
  )
  out[is.na(es)] <- NA_character_
  out
}

#' Baseline equivalence table for an impact evaluation
#'
#' Builds a report-ready baseline-equivalence table for a set of continuous
#' covariates, reporting group sample sizes, means, standard deviations,
#' Hedges' g, and the corresponding What Works Clearinghouse (WWC) equivalence
#' category for each covariate.
#'
#' @param data A data frame.
#' @param treatment String naming the column in `data` that identifies group
#'   membership. Must have exactly two unique non-missing values (see
#'   [hedges_g()] for how the treatment group is determined).
#' @param covariates Character vector of column names to evaluate. Defaults to
#'   all numeric columns in `data` other than `treatment`.
#'
#' @return A data frame with one row per covariate and the columns
#'   `covariate`, `n_treatment`, `n_comparison`, `mean_treatment`,
#'   `mean_comparison`, `sd_treatment`, `sd_comparison`, `hedges_g`, and
#'   `wwc_category`.
#'
#' @section Scope:
#' Version 0.1.0 supports continuous covariates only. Binary covariates (via
#' the WWC Cox index) are on the roadmap; see `NEWS.md`.
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' df <- data.frame(
#'   treat = c(1, 1, 1, 0, 0, 0),
#'   pretest = c(5, 6, 7, 4, 5, 6)
#' )
#' baseline_equivalence(df, treatment = "treat")
#'
#' @export
baseline_equivalence <- function(data, treatment, covariates = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.character(treatment) || length(treatment) != 1L) {
    stop("`treatment` must be a single column name (a string).", call. = FALSE)
  }
  if (!treatment %in% names(data)) {
    stop(sprintf("Column '%s' not found in `data`.", treatment), call. = FALSE)
  }
  grp <- data[[treatment]]
  levs <- sort(unique(grp[!is.na(grp)]))
  if (length(levs) != 2L) {
    stop("The `treatment` column must have exactly two unique non-missing values.",
      call. = FALSE
    )
  }
  if (is.null(covariates)) {
    is_num <- vapply(data, is.numeric, logical(1))
    covariates <- setdiff(names(data)[is_num], treatment)
  }
  if (length(covariates) == 0L) {
    stop("No covariates to evaluate.", call. = FALSE)
  }
  missing_cov <- setdiff(covariates, names(data))
  if (length(missing_cov) > 0L) {
    stop(sprintf(
      "Columns not found in `data`: %s",
      paste(missing_cov, collapse = ", ")
    ), call. = FALSE)
  }

  rows <- lapply(covariates, function(cv) {
    x <- data[[cv]]
    if (!is.numeric(x)) {
      stop(sprintf(
        "Covariate '%s' is not numeric (v0.1.0 supports continuous covariates only).",
        cv
      ), call. = FALSE)
    }
    keep <- !is.na(x) & !is.na(grp)
    xk <- x[keep]
    gk <- grp[keep]
    comparison <- xk[gk == levs[1]]
    treated <- xk[gk == levs[2]]
    data.frame(
      covariate = cv,
      n_treatment = length(treated),
      n_comparison = length(comparison),
      mean_treatment = mean(treated),
      mean_comparison = mean(comparison),
      sd_treatment = sd(treated),
      sd_comparison = sd(comparison),
      hedges_g = hedges_g(xk, gk),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out$wwc_category <- wwc_classify(out$hedges_g)
  rownames(out) <- NULL
  out
}
