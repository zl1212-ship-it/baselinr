# Baseline equivalence table for an impact evaluation

Builds a report-ready baseline-equivalence table for a set of
covariates, reporting group sample sizes, summaries, the appropriate
standardized effect size, and the corresponding What Works Clearinghouse
(WWC) equivalence category for each covariate. Continuous covariates use
Hedges' g; binary covariates use the Cox index.

## Usage

``` r
baseline_equivalence(
  data,
  treatment,
  covariates = NULL,
  missing = c("pairwise", "complete"),
  report_missing = FALSE
)
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

  Character vector of column names to evaluate. Defaults to all numeric,
  logical, and factor columns in `data` other than `treatment`.

- missing:

  How to handle missing covariate values. `"pairwise"` (the default, and
  the behavior of earlier versions) computes each covariate's row from
  the cases non-missing on that covariate and on `treatment`, so rows
  can describe different subsets. `"complete"` restricts every row to
  the cases complete on `treatment` and on all evaluated covariates, so
  every row describes the same set of cases.

- report_missing:

  Logical; if `TRUE`, adds `missing_treatment` and `missing_comparison`
  columns reporting each group's proportion of missing values on the
  covariate. The rates are computed on all cases with a non-missing
  `treatment` value, before any deletion, under either setting of
  `missing`. Default `FALSE`.

## Value

A data frame with one row per covariate and the columns: `covariate`;
`type` (`"continuous"` or `"binary"`); `n_treatment`, `n_comparison`;
`mean_treatment`, `mean_comparison` (group means for continuous
covariates, event proportions for binary ones); `sd_treatment`,
`sd_comparison`; `effect_size` (Hedges' g or Cox index, per `type`); and
`wwc_category`. If `report_missing = TRUE`, the columns
`missing_treatment` and `missing_comparison` appear after the
sample-size columns.

## Details

A covariate with exactly two unique non-missing values is treated as
binary; any other numeric covariate is treated as continuous. A
non-numeric covariate with more than two categories is not supported and
raises an error. The binary-versus-continuous decision uses the sample
actually contributing to the row, so it can differ between
`missing = "pairwise"` and `missing = "complete"` when deletion removes
all cases at one value.

Under WWC review, baseline equivalence must be established on the
analytic sample, the cases actually contributing to the impact estimate.
This function sees only the covariates, never the outcome, so neither
option identifies the analytic sample by itself; to establish
equivalence on the analytic sample, pass that subset of cases as `data`.
Within the data supplied, `missing = "complete"` keeps every row on one
common set of cases, as a complete-case analysis would, while
`"pairwise"` uses all available information per covariate.
`report_missing = TRUE` documents how much is missing in each group,
complementing the sample-loss reporting in
[`attrition()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition.md).

## References

What Works Clearinghouse (2022). *Procedures and Standards Handbook*
(Version 5.0). U.S. Department of Education.

## Examples

``` r
df <- data.frame(
  treat = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6),
  female = c(1, 0, 1, 0, 0, 1)
)
baseline_equivalence(df, treatment = "treat")
#>   covariate       type n_treatment n_comparison mean_treatment mean_comparison
#> 1   pretest continuous           3            3      6.0000000       5.0000000
#> 2    female     binary           3            3      0.6666667       0.3333333
#>   sd_treatment sd_comparison effect_size  wwc_category
#> 1    1.0000000     1.0000000   0.8000000 not_satisfied
#> 2    0.5773503     0.5773503   0.8401784 not_satisfied
```
