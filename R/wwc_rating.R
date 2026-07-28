#' WWC group-design study rating
#'
#' Applies the What Works Clearinghouse (WWC) group-design rating logic to the
#' two determinations this package supports, sample attrition and baseline
#' equivalence, and returns the study's rating. This encodes the main decision
#' path of the WWC Standards Handbook (Version 4.1, Section II): a randomized
#' controlled trial (RCT) with low attrition can meet standards without
#' reservations; an RCT with high attrition is held to the same baseline
#' requirement as a quasi-experimental design (QED); and a QED, or a high
#' attrition RCT, meets standards with reservations only if baseline equivalence
#' is established, and otherwise does not meet standards.
#'
#' This function covers the attrition-and-equivalence path only. A real WWC
#' review also checks that random assignment was not compromised, that there are
#' no confounding factors, and that the required baseline measures were used;
#' those judgments are the reviewer's and are assumed satisfied here.
#'
#' @param design `"rct"` or `"qed"`.
#' @param baseline The overall baseline-equivalence verdict, one of
#'   `"satisfied"`, `"satisfied_with_adjustment"`, or `"not_satisfied"` (the
#'   `overall` value from [wwc_summary()]).
#' @param attrition For an RCT, `"low"` or `"high"` (the `attrition` value from
#'   [attrition_boundary()]); required for `design = "rct"`, ignored for a QED.
#'
#' @return A length-one character string: one of
#'   `"Meets WWC Group Design Standards Without Reservations"`,
#'   `"Meets WWC Group Design Standards With Reservations"`, or
#'   `"Does Not Meet WWC Group Design Standards"`. The reasoning is attached as
#'   `attr(x, "basis")`.
#'
#' @references What Works Clearinghouse (2020). *Standards Handbook, Version
#'   4.1*, Section II. U.S. Department of Education.
#'
#' @examples
#' # Low-attrition RCT: meets without reservations regardless of baseline.
#' wwc_rating("rct", baseline = "not_satisfied", attrition = "low")
#'
#' # High-attrition RCT hinges on baseline equivalence, like a QED.
#' wwc_rating("rct", baseline = "satisfied_with_adjustment", attrition = "high")
#'
#' # QED that fails baseline equivalence does not meet standards.
#' wwc_rating("qed", baseline = "not_satisfied")
#'
#' @export
wwc_rating <- function(design, baseline, attrition = NULL) {
  design <- match.arg(tolower(design), c("rct", "qed"))
  baseline <- match.arg(
    baseline,
    c("satisfied", "satisfied_with_adjustment", "not_satisfied")
  )
  baseline_ok <- baseline %in% c("satisfied", "satisfied_with_adjustment")

  without <- "Meets WWC Group Design Standards Without Reservations"
  with_res <- "Meets WWC Group Design Standards With Reservations"
  does_not <- "Does Not Meet WWC Group Design Standards"

  if (identical(design, "rct")) {
    if (is.null(attrition)) {
      stop("`attrition` (\"low\" or \"high\") is required for an RCT.",
        call. = FALSE
      )
    }
    attrition <- match.arg(attrition, c("low", "high"))
    if (identical(attrition, "low")) {
      rating <- without
      basis <- paste(
        "RCT with low attrition: random assignment establishes equivalence,",
        "so the study can meet standards without reservations."
      )
    } else {
      rating <- if (baseline_ok) with_res else does_not
      basis <- paste(
        "RCT with high attrition is held to the QED baseline requirement;",
        if (baseline_ok) {
          "baseline equivalence is established, so it meets with reservations."
        } else {
          "baseline equivalence is not established, so it does not meet standards."
        }
      )
    }
  } else {
    rating <- if (baseline_ok) with_res else does_not
    basis <- paste(
      "QED cannot meet without reservations;",
      if (baseline_ok) {
        "baseline equivalence is established, so it meets with reservations."
      } else {
        "baseline equivalence is not established, so it does not meet standards."
      }
    )
  }
  attr(rating, "basis") <- basis
  rating
}
