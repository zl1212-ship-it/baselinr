# Baseline equivalence table for an impact evaluation

Builds a report-ready baseline-equivalence table for a set of
covariates, reporting group sample sizes, summaries, the appropriate
standardized effect size, and the corresponding What Works Clearinghouse
(WWC) equivalence category for each covariate. Continuous covariates use
Hedges' g; binary covariates use the Cox index.

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

  Character vector of column names to evaluate. Defaults to all numeric,
  logical, and factor columns in `data` other than `treatment`.

## Value

A data frame with one row per covariate and the columns: `covariate`;
`type` (`"continuous"` or `"binary"`); `n_treatment`, `n_comparison`;
`mean_treatment`, `mean_comparison` (group means for continuous
covariates, event proportions for binary ones); `sd_treatment`,
`sd_comparison`; `effect_size` (Hedges' g or Cox index, per `type`); and
`wwc_category`.

## Details

A covariate with exactly two unique non-missing values is treated as
binary; any other numeric covariate is treated as continuous. A
non-numeric covariate with more than two categories is not supported and
raises an error.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

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
