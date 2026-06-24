# Overall WWC baseline-equivalence verdict

Summarizes a
[`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md)
table into a one-row overall assessment: how many covariates fall in
each What Works Clearinghouse (WWC) category, the largest absolute
effect size, and an overall verdict.

## Usage

``` r
wwc_summary(equivalence)
```

## Arguments

- equivalence:

  A data frame returned by
  [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md).

## Value

A one-row data frame with columns `n_covariates`, `n_satisfied`,
`n_satisfied_with_adjustment`, `n_not_satisfied`, `max_abs_effect`, and
`overall`.

## Details

The overall verdict follows the logic of the categories: if any
covariate is `"not_satisfied"`, baseline equivalence cannot be
established (`"not_satisfied"`); otherwise, if any covariate requires
adjustment, the verdict is `"satisfied_with_adjustment"` (equivalence
holds only if those covariates are adjusted for in the impact model);
otherwise `"satisfied"`.

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
wwc_summary(baseline_equivalence(df, "treat"))
#>   n_covariates n_satisfied n_satisfied_with_adjustment n_not_satisfied
#> 1            2           0                           0               2
#>   max_abs_effect       overall
#> 1      0.8401784 not_satisfied
```
