#' Love plot of standardized effect sizes
#'
#' Plots the standardized effect size for each covariate from
#' [baseline_equivalence()], with reference lines at the What Works
#' Clearinghouse (WWC) thresholds (0.05 and 0.25) and points coloured by WWC
#' category. Requires the \pkg{ggplot2} package.
#'
#' @param equivalence A data frame returned by [baseline_equivalence()].
#' @param signed Logical. If `FALSE` (default), plot absolute effect sizes with
#'   reference lines at 0.05 and 0.25. If `TRUE`, plot signed effect sizes with
#'   symmetric reference lines and a line at zero.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   df <- data.frame(
#'     treat = c(1, 1, 1, 0, 0, 0),
#'     pretest = c(5, 6, 7, 4, 5, 6),
#'     female = c(1, 0, 1, 0, 0, 1)
#'   )
#'   love_plot(baseline_equivalence(df, "treat"))
#' }
#'
#' @importFrom stats reorder
#' @importFrom rlang .data
#' @export
love_plot <- function(equivalence, signed = FALSE) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "`love_plot()` requires the 'ggplot2' package. ",
      "Install it with install.packages('ggplot2').",
      call. = FALSE
    )
  }
  required <- c("covariate", "effect_size", "wwc_category")
  if (!is.data.frame(equivalence) || !all(required %in% names(equivalence))) {
    stop("`equivalence` must be a data frame from `baseline_equivalence()`.",
      call. = FALSE
    )
  }

  df <- equivalence
  df$plot_value <- if (isTRUE(signed)) df$effect_size else abs(df$effect_size)
  df$covariate <- reorder(df$covariate, df$plot_value)
  thresholds <- if (isTRUE(signed)) c(-0.25, -0.05, 0.05, 0.25) else c(0.05, 0.25)
  x_lab <- if (isTRUE(signed)) {
    "Standardized effect size"
  } else {
    "Absolute standardized effect size"
  }

  # `.data` is the rlang pronoun (imported); lintr's usage linter flags it as a
  # false positive, so it is silenced for this block.
  # nolint start: object_usage_linter.
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[["plot_value"]],
      y = .data[["covariate"]],
      colour = .data[["wwc_category"]]
    )
  ) +
    # nolint end
    ggplot2::geom_vline(
      xintercept = thresholds, linetype = "dashed", colour = "grey60"
    )
  if (isTRUE(signed)) {
    p <- p + ggplot2::geom_vline(xintercept = 0, colour = "grey40")
  }
  p +
    ggplot2::geom_point(size = 3) +
    ggplot2::scale_colour_manual(
      values = c(
        satisfied = "#1b9e77",
        satisfied_with_adjustment = "#d95f02",
        not_satisfied = "#d7191c"
      ),
      drop = FALSE
    ) +
    ggplot2::labs(
      x = x_lab, y = NULL, colour = "WWC category",
      title = "Baseline equivalence"
    ) +
    ggplot2::theme_minimal()
}

#' Format a baseline equivalence table with gt
#'
#' Renders the result of [baseline_equivalence()] as a formatted \pkg{gt} table
#' with rounded statistics and readable column labels. Requires the \pkg{gt}
#' package.
#'
#' @param equivalence A data frame returned by [baseline_equivalence()].
#' @param decimals Number of decimal places for the numeric columns. Default 2.
#'
#' @return A `gt_tbl` object.
#'
#' @examples
#' if (requireNamespace("gt", quietly = TRUE)) {
#'   df <- data.frame(
#'     treat = c(1, 1, 1, 0, 0, 0),
#'     pretest = c(5, 6, 7, 4, 5, 6),
#'     female = c(1, 0, 1, 0, 0, 1)
#'   )
#'   tbl <- gt_baseline(baseline_equivalence(df, "treat"))
#' }
#'
#' @export
gt_baseline <- function(equivalence, decimals = 2) {
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop(
      "`gt_baseline()` requires the 'gt' package. ",
      "Install it with install.packages('gt').",
      call. = FALSE
    )
  }
  required <- c("covariate", "effect_size", "wwc_category")
  if (!is.data.frame(equivalence) || !all(required %in% names(equivalence))) {
    stop("`equivalence` must be a data frame from `baseline_equivalence()`.",
      call. = FALSE
    )
  }

  num_cols <- intersect(
    c(
      "mean_treatment", "mean_comparison",
      "sd_treatment", "sd_comparison", "effect_size"
    ),
    names(equivalence)
  )
  labels <- list(
    covariate = "Covariate", type = "Type",
    n_treatment = "n (T)", n_comparison = "n (C)",
    mean_treatment = "Mean/Prop (T)", mean_comparison = "Mean/Prop (C)",
    sd_treatment = "SD (T)", sd_comparison = "SD (C)",
    effect_size = "Effect size", wwc_category = "WWC category"
  )
  labels <- labels[names(labels) %in% names(equivalence)]

  tbl <- gt::gt(equivalence)
  tbl <- gt::fmt_number(tbl, columns = num_cols, decimals = decimals)
  tbl <- gt::cols_label(tbl, .list = labels)
  gt::tab_header(
    tbl,
    title = "Baseline equivalence",
    subtitle = "Hedges' g (continuous) / Cox index (binary), with WWC categories"
  )
}
