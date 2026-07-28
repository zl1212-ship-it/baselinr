#' Robustness of the WWC baseline-equivalence verdict
#'
#' Reports how stable a baseline-equivalence verdict is to the computation
#' choices a careful analyst might defensibly make differently. For each
#' continuous covariate it recomputes the standardized difference under the
#' cross of two choices, standardizing by the pooled versus the comparison-group
#' standard deviation and applying the What Works Clearinghouse (WWC)
#' small-sample correction or not, and records whether the covariate's WWC
#' category changes. Binary covariates use the Cox index, which does not depend
#' on these choices. It also reports whether the overall verdict changes.
#'
#' This is a multiverse, or specification-curve, view of a single WWC
#' determination: it shows whether the verdict depends on which defensible
#' choice is made.
#'
#' @param data A data frame.
#' @param treatment String naming the treatment-indicator column (see
#'   [baseline_equivalence()]).
#' @param covariates Character vector of covariate columns. Defaults to all
#'   eligible columns other than `treatment`.
#'
#' @return A data frame with one row per covariate and the columns `covariate`,
#'   `type`, `category_default` (the category under baselinr's default), the set
#'   of `categories` the covariate takes across the defensible choices, `flips`
#'   (whether that set has more than one category), and `abs_es_min` /
#'   `abs_es_max` (the range of the absolute effect size across choices). The
#'   overall verdict under each choice is attached as `attr(x, "overall")`, and
#'   `attr(x, "overall_stable")` is `TRUE` when the overall verdict is invariant.
#'
#' @references What Works Clearinghouse (2022). *Procedures Handbook*
#'   (Version 5.0). U.S. Department of Education. Steegen, S., Tuerlinckx, F.,
#'   Gelman, A., & Vanpaemel, W. (2016). Increasing transparency through a
#'   multiverse analysis. *Perspectives on Psychological Science*, 11(5), 702-712.
#'
#' @examples
#' df <- data.frame(
#'   treat = c(1, 1, 1, 0, 0, 0),
#'   pretest = c(5, 6, 7, 4, 5, 6),
#'   female = c(1, 0, 1, 0, 0, 1)
#' )
#' r <- wwc_robustness(df, treatment = "treat")
#' r
#' attr(r, "overall")
#'
#' @importFrom stats var sd
#' @export
wwc_robustness <- function(data, treatment, covariates = NULL) {
  base <- baseline_equivalence(data, treatment, covariates)
  covs <- base$covariate
  grp <- data[[treatment]]
  levs <- sort(unique(grp[!is.na(grp)]))

  choices <- expand.grid(
    sd_type = c("pooled", "comparison"),
    correction = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )

  # Effect size for one covariate under one (sd_type, correction) choice.
  # Binary covariates use the Cox index and are invariant to these choices.
  es_one <- function(cv, sd_type, correction) {
    x <- data[[cv]]
    keep <- !is.na(x) & !is.na(grp)
    xk <- x[keep]
    gk <- grp[keep]
    if (length(unique(xk)) == 2L) {
      return(cox_index(xk, gk))
    }
    xt <- xk[gk == levs[2]]
    xc <- xk[gk == levs[1]]
    n_t <- length(xt)
    n_c <- length(xc)
    s <- if (identical(sd_type, "pooled")) {
      sqrt(((n_t - 1) * var(xt) + (n_c - 1) * var(xc)) / (n_t + n_c - 2))
    } else {
      sd(xc)
    }
    d <- (mean(xt) - mean(xc)) / s
    if (isTRUE(correction)) d <- d * (1 - 3 / (4 * (n_t + n_c) - 9))
    d
  }

  per <- lapply(seq_along(covs), function(i) {
    cv <- covs[i]
    es_vals <- mapply(es_one, cv, choices$sd_type, choices$correction)
    cats <- unique(wwc_classify(es_vals))
    data.frame(
      covariate = cv,
      type = base$type[i],
      category_default = base$wwc_category[i],
      categories = paste(sort(cats), collapse = " | "),
      flips = length(cats) > 1L,
      abs_es_min = min(abs(es_vals)),
      abs_es_max = max(abs(es_vals)),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, per)

  overall_one <- function(sd_type, correction) {
    es_all <- vapply(
      covs, es_one, numeric(1),
      sd_type = sd_type, correction = correction
    )
    cat <- wwc_classify(es_all)
    if (any(cat == "not_satisfied", na.rm = TRUE)) {
      "not_satisfied"
    } else if (any(cat == "satisfied_with_adjustment", na.rm = TRUE)) {
      "satisfied_with_adjustment"
    } else {
      "satisfied"
    }
  }
  ov <- data.frame(
    choices,
    overall = mapply(overall_one, choices$sd_type, choices$correction),
    stringsAsFactors = FALSE
  )
  attr(out, "overall") <- ov
  attr(out, "overall_stable") <- length(unique(ov$overall)) == 1L
  rownames(out) <- NULL
  out
}
