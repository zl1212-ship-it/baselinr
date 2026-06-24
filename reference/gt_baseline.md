# Format a baseline equivalence table with gt

Renders the result of
[`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md)
as a formatted gt table with rounded statistics and readable column
labels. Requires the gt package.

## Usage

``` r
gt_baseline(equivalence, decimals = 2)
```

## Arguments

- equivalence:

  A data frame returned by
  [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md).

- decimals:

  Number of decimal places for the numeric columns. Default 2.

## Value

A `gt_tbl` object.

## Examples

``` r
if (requireNamespace("gt", quietly = TRUE)) {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  tbl <- gt_baseline(baseline_equivalence(df, "treat"))
}
```
