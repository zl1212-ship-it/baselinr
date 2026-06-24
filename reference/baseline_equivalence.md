# Baseline equivalence table for an impact evaluation

Builds a report-ready baseline-equivalence table for a set of continuous
covariates, reporting group sample sizes, means, standard deviations,
Hedges' g, and the corresponding What Works Clearinghouse (WWC)
equivalence category for each covariate.

## Usage

``` r
baseline_equivalence(data, treatment, covariates = NULL)
```

## Arguments

- data:

  A data frame.

- treatment:

  String naming the column in `data` that identifies group membership.
  Must have exactly two unique non-missing values (see
  [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md)
  for how the treatment group is determined).

- covariates:

  Character vector of column names to evaluate. Defaults to all numeric
  columns in `data` other than `treatment`.

## Value

A data frame with one row per covariate and the columns `covariate`,
`n_treatment`, `n_comparison`, `mean_treatment`, `mean_comparison`,
`sd_treatment`, `sd_comparison`, `hedges_g`, and `wwc_category`.

## Scope

Version 0.1.0 supports continuous covariates only. Binary covariates
(via the WWC Cox index) are on the roadmap; see `NEWS.md`.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

## Examples

``` r
df <- data.frame(
  treat = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6)
)
baseline_equivalence(df, treatment = "treat")
#>   covariate n_treatment n_comparison mean_treatment mean_comparison
#> 1   pretest           3            3              6               5
#>   sd_treatment sd_comparison hedges_g  wwc_category
#> 1            1             1      0.8 not_satisfied
```
