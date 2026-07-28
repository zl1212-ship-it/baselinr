# What Works Clearinghouse attrition boundary, Standards Handbook Version 4.1,
# Table II.1 ("Highest differential attrition rate for a sample to maintain low
# attrition, by overall attrition rate, under 'optimistic' and 'cautious'
# assumptions"). Overall attrition is a percentage (0-65); the boundary values
# are the highest differential attrition, in percentage points, still counted as
# low attrition. Under the cautious assumption, an overall attrition rate of 58
# percent or more is high attrition for any differential (NA below).
.wwc_attrition_table <- function() {
  data.frame(
    overall = 0:65,
    cautious = c(
      5.7, 5.8, 5.9, 5.9, 6.0, 6.1, 6.2, 6.3, 6.3, 6.3, 6.3, 6.2, 6.2, 6.1, 6.0,
      5.9, 5.9, 5.8, 5.7, 5.5, 5.4, 5.3, 5.2, 5.1, 4.9, 4.8, 4.7, 4.5, 4.4, 4.3,
      4.1, 4.0, 3.8, 3.6, 3.5, 3.3, 3.2, 3.1, 2.9, 2.8, 2.6, 2.5, 2.3, 2.1, 2.0,
      1.8, 1.6, 1.5, 1.3, 1.2, 1.0, 0.9, 0.7, 0.6, 0.4, 0.3, 0.2, 0.0,
      NA, NA, NA, NA, NA, NA, NA, NA
    ),
    optimistic = c(
      10.0, 10.1, 10.2, 10.3, 10.4, 10.5, 10.7, 10.8, 10.9, 10.9, 10.9, 10.9,
      10.9, 10.8, 10.8, 10.7, 10.6, 10.5, 10.3, 10.2, 10.0, 9.9, 9.7, 9.5, 9.4,
      9.2, 9.0, 8.8, 8.6, 8.4, 8.2, 8.0, 7.8, 7.6, 7.4, 7.2, 7.0, 6.7, 6.5, 6.3,
      6.0, 5.8, 5.6, 5.3, 5.1, 4.9, 4.6, 4.4, 4.2, 3.9, 3.7, 3.5, 3.2, 3.0, 2.8,
      2.6, 2.3, 2.1, 1.9, 1.6, 1.4, 1.1, 0.9, 0.7, 0.5, 0.3
    )
  )
}

#' Classify a study under the WWC attrition standard
#'
#' Given a study's overall and differential attrition, classifies it as low or
#' high attrition against the What Works Clearinghouse (WWC) attrition boundary
#' (Standards Handbook Version 4.1, Table II.1). This is the classification that
#' [attrition()] deliberately leaves to the user: [attrition()] reports the
#' rates, `attrition_boundary()` applies the standard.
#'
#' The WWC uses one of two boundaries. The **cautious** boundary is applied when
#' the intervention could plausibly affect attrition (for example, a dropout
#' prevention program); the **optimistic** boundary when it is unlikely to (for
#' example, a first-grade reading program). The applicable boundary is set by the
#' review protocol, not chosen post hoc; the default here is the more
#' conservative cautious boundary.
#'
#' @param overall Overall attrition, as a proportion in `[0, 1]` (as returned by
#'   [attrition()]).
#' @param differential Differential attrition, as a proportion (the absolute
#'   difference in group attrition rates, as returned by [attrition()]).
#' @param assumption Which boundary to apply: `"cautious"` (default) or
#'   `"optimistic"`.
#'
#' @return A data frame, one row per input, with columns `overall`,
#'   `differential`, `assumption`, `max_differential` (the highest differential
#'   attrition still counted as low, as a proportion; `NA` where the overall rate
#'   is beyond the boundary), and `attrition` (`"low"` or `"high"`).
#'
#' @references What Works Clearinghouse (2020). *Standards Handbook, Version
#'   4.1*, Table II.1. U.S. Department of Education.
#'
#' @examples
#' # A study with 8% overall and 3 percentage-point differential attrition:
#' attrition_boundary(0.08, 0.03) # low under the cautious boundary
#'
#' # 30% overall, 6-point differential: high if cautious, low if optimistic
#' attrition_boundary(0.30, 0.06, "cautious")
#' attrition_boundary(0.30, 0.06, "optimistic")
#'
#' # Chained from attrition():
#' set.seed(1)
#' g <- rep(c(1, 0), each = 100)
#' kept <- rbinom(200, 1, ifelse(g == 1, 0.9, 0.82))
#' a <- attrition(g, kept)
#' attrition_boundary(a$attrition_overall, a$differential_attrition)
#'
#' @export
attrition_boundary <- function(overall, differential,
                               assumption = c("cautious", "optimistic")) {
  assumption <- match.arg(assumption)
  if (length(overall) != length(differential)) {
    stop("`overall` and `differential` must have the same length.", call. = FALSE)
  }
  if (any(overall > 1, na.rm = TRUE) || any(differential > 1, na.rm = TRUE)) {
    warning(
      "`overall`/`differential` should be proportions in [0, 1] (as returned ",
      "by attrition()); values > 1 look like percentages.",
      call. = FALSE
    )
  }
  tab <- .wwc_attrition_table()
  bcol <- if (identical(assumption, "cautious")) tab$cautious else tab$optimistic

  o_pct <- round(overall * 100)
  diff_pp <- differential * 100
  boundary_pp <- rep(NA_real_, length(o_pct))
  in_range <- !is.na(o_pct) & o_pct >= 0 & o_pct <= 65
  boundary_pp[in_range] <- bcol[match(o_pct[in_range], tab$overall)]

  valid <- !is.na(o_pct) & !is.na(diff_pp)
  cls <- rep(NA_character_, length(o_pct))
  # tolerance so a differential sitting exactly on the boundary is not pushed
  # over by floating-point error (e.g. 0.014 * 100 = 1.4000000000000001)
  cls[valid] <- ifelse(
    is.na(boundary_pp[valid]), "high",
    ifelse(diff_pp[valid] <= boundary_pp[valid] + 1e-8, "low", "high")
  )

  data.frame(
    overall = overall,
    differential = differential,
    assumption = assumption,
    max_differential = boundary_pp / 100,
    attrition = cls,
    stringsAsFactors = FALSE
  )
}
