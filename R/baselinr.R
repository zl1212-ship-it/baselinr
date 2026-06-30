#' baselinr: WWC-aligned baseline equivalence for education impact evaluations
#'
#' baselinr produces report-ready baseline equivalence tables for impact
#' evaluations in education research, following the conventions of the What
#' Works Clearinghouse (WWC). It takes a data frame, a treatment indicator, and
#' a set of covariates, and reports, for each covariate, the appropriate
#' standardized effect size (Hedges' g for continuous covariates, the Cox index
#' for binary covariates) together with the WWC baseline-equivalence category.
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
#' @importFrom stats var sd qlogis
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

#' Cox index for a binary covariate
#'
#' Computes the What Works Clearinghouse (WWC) Cox index, a standardized effect
#' size for a binary (dichotomous) covariate. The Cox index places the
#' difference between two proportions on a scale comparable to Hedges' g, so it
#' can be classified with the same baseline-equivalence thresholds.
#'
#' The index is \eqn{d_{Cox} = (\mathrm{logit}(p_t) - \mathrm{logit}(p_c)) /
#' 1.65}, where \eqn{p_t} and \eqn{p_c} are the proportions in the "event"
#' category for the treatment and comparison groups.
#'
#' @param x A binary covariate (numeric `0/1`, logical, two-level factor, or any
#'   vector with exactly two unique non-missing values). The larger value (e.g.
#'   `1`, `TRUE`, or the second sorted level) is treated as the "event".
#' @param treatment Vector the same length as `x` identifying group membership;
#'   exactly two unique non-missing values (see [hedges_g()]).
#' @param na.rm Logical; drop rows where `x` or `treatment` is `NA`.
#'   Default `TRUE`.
#'
#' @return A single numeric value: the Cox index. Returns `NA` (with a warning)
#'   when a group proportion is exactly 0 or 1, where the index is undefined.
#'
#' @references What Works Clearinghouse (2022).
#'   *Procedures Handbook* (Version 5.0). U.S. Department of Education.
#'
#' @examples
#' x <- c(1, 1, 1, 1, 0, 1, 0, 0)
#' g <- c(1, 1, 1, 1, 0, 0, 0, 0)
#' cox_index(x, g)
#'
#' @export
cox_index <- function(x, treatment, na.rm = TRUE) {
  if (length(x) != length(treatment)) {
    stop("`x` and `treatment` must have the same length.", call. = FALSE)
  }
  if (isTRUE(na.rm)) {
    keep <- !is.na(x) & !is.na(treatment)
    x <- x[keep]
    treatment <- treatment[keep]
  }
  x_levs <- sort(unique(x))
  if (length(x_levs) != 2L) {
    stop("`x` must be binary (exactly two unique non-missing values).",
      call. = FALSE
    )
  }
  t_levs <- sort(unique(treatment))
  if (length(t_levs) != 2L) {
    stop("`treatment` must have exactly two unique non-missing values.",
      call. = FALSE
    )
  }
  event <- x_levs[2]
  is_event <- x == event
  p_t <- mean(is_event[treatment == t_levs[2]])
  p_c <- mean(is_event[treatment == t_levs[1]])
  if (p_t %in% c(0, 1) || p_c %in% c(0, 1)) {
    warning(
      "Cox index is undefined when a group proportion is 0 or 1; returning NA.",
      call. = FALSE
    )
    return(NA_real_)
  }
  (qlogis(p_t) - qlogis(p_c)) / 1.65
}

#' Classify baseline equivalence under WWC standards
#'
#' Maps standardized effect sizes to the three What Works Clearinghouse
#' baseline-equivalence categories. Sign is ignored; classification uses the
#' absolute value of the effect size.
#'
#' @param es Numeric vector of standardized effect sizes (e.g. values returned
#'   by [hedges_g()] or [cox_index()]).
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
#' Builds a report-ready baseline-equivalence table for a set of covariates,
#' reporting group sample sizes, summaries, the appropriate standardized effect
#' size, and the corresponding What Works Clearinghouse (WWC) equivalence
#' category for each covariate. Continuous covariates use Hedges' g; binary
#' covariates use the Cox index.
#'
#' @param data A data frame.
#' @param treatment String naming the column in `data` that identifies group
#'   membership. Must have exactly two unique non-missing values (see
#'   [hedges_g()] for how the treatment group is determined).
#' @param covariates Character vector of column names to evaluate. Defaults to
#'   all numeric, logical, and factor columns in `data` other than `treatment`.
#'
#' @return A data frame with one row per covariate and the columns:
#'   `covariate`; `type` (`"continuous"` or `"binary"`); `n_treatment`,
#'   `n_comparison`; `mean_treatment`, `mean_comparison` (group means for
#'   continuous covariates, event proportions for binary ones); `sd_treatment`,
#'   `sd_comparison`; `effect_size` (Hedges' g or Cox index, per `type`); and
#'   `wwc_category`.
#'
#' @details
#' A covariate with exactly two unique non-missing values is treated as binary;
#' any other numeric covariate is treated as continuous. A non-numeric covariate
#' with more than two categories is not supported and raises an error.
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
    eligible <- vapply(
      data,
      function(col) is.numeric(col) || is.logical(col) || is.factor(col),
      logical(1)
    )
    covariates <- setdiff(names(data)[eligible], treatment)
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
    .baseline_row(cv, data[[cv]], grp, levs)
  })
  out <- do.call(rbind, rows)
  out$wwc_category <- wwc_classify(out$effect_size)
  rownames(out) <- NULL
  out
}

# Internal: build one table row for a single covariate.
.baseline_row <- function(cv, x, grp, levs) {
  keep <- !is.na(x) & !is.na(grp)
  xk <- x[keep]
  gk <- grp[keep]
  treat_idx <- gk == levs[2]
  comp_idx <- gk == levs[1]
  uniq <- unique(xk)

  if (length(uniq) == 2L) {
    # Binary covariate -> Cox index; summaries are event proportions.
    event <- sort(uniq)[2]
    ind <- as.integer(xk == event)
    row <- data.frame(
      covariate = cv,
      type = "binary",
      n_treatment = sum(treat_idx),
      n_comparison = sum(comp_idx),
      mean_treatment = mean(ind[treat_idx]),
      mean_comparison = mean(ind[comp_idx]),
      sd_treatment = sd(ind[treat_idx]),
      sd_comparison = sd(ind[comp_idx]),
      effect_size = cox_index(xk, gk),
      stringsAsFactors = FALSE
    )
  } else {
    if (!is.numeric(xk)) {
      stop(sprintf(
        "Covariate '%s' has more than two categories and is not numeric; not supported.",
        cv
      ), call. = FALSE)
    }
    row <- data.frame(
      covariate = cv,
      type = "continuous",
      n_treatment = sum(treat_idx),
      n_comparison = sum(comp_idx),
      mean_treatment = mean(xk[treat_idx]),
      mean_comparison = mean(xk[comp_idx]),
      sd_treatment = sd(xk[treat_idx]),
      sd_comparison = sd(xk[comp_idx]),
      effect_size = hedges_g(xk, gk),
      stringsAsFactors = FALSE
    )
  }
  row
}
