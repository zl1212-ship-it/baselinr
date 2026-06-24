# Love plot of standardized effect sizes

Plots the standardized effect size for each covariate from
[`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md),
with reference lines at the What Works Clearinghouse (WWC) thresholds
(0.05 and 0.25) and points coloured by WWC category. Requires the
ggplot2 package.

## Usage

``` r
love_plot(equivalence, signed = FALSE)
```

## Arguments

- equivalence:

  A data frame returned by
  [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md).

- signed:

  Logical. If `FALSE` (default), plot absolute effect sizes with
  reference lines at 0.05 and 0.25. If `TRUE`, plot signed effect sizes
  with symmetric reference lines and a line at zero.

## Value

A `ggplot` object.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  love_plot(baseline_equivalence(df, "treat"))
}

```
