# Robustness of the WWC baseline-equivalence verdict

Reports how stable a baseline-equivalence verdict is to the computation
choices a careful analyst might defensibly make differently. For each
continuous covariate it recomputes the standardized difference under the
cross of two choices, standardizing by the pooled versus the
comparison-group standard deviation and applying the What Works
Clearinghouse (WWC) small-sample correction or not, and records whether
the covariate's WWC category changes. Binary covariates use the Cox
index, which does not depend on these choices. It also reports whether
the overall verdict changes.

## Usage

``` r
wwc_robustness(data, treatment, covariates = NULL)
```

## Arguments

- data:

  A data frame.

- treatment:

  String naming the treatment-indicator column (see
  [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md)).

- covariates:

  Character vector of covariate columns. Defaults to all eligible
  columns other than `treatment`.

## Value

A data frame with one row per covariate and the columns `covariate`,
`type`, `category_default` (the category under baselinr's default), the
set of `categories` the covariate takes across the defensible choices,
`flips` (whether that set has more than one category), and `abs_es_min`
/ `abs_es_max` (the range of the absolute effect size across choices).
The overall verdict under each choice is attached as
`attr(x, "overall")`, and `attr(x, "overall_stable")` is `TRUE` when the
overall verdict is invariant.

## Details

This is a multiverse, or specification-curve, view of a single WWC
determination: it shows whether the verdict depends on which defensible
choice is made.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education. Steegen, S., Tuerlinckx, F., Gelman, A., &
Vanpaemel, W. (2016). Increasing transparency through a multiverse
analysis. *Perspectives on Psychological Science*, 11(5), 702-712.

## Examples

``` r
df <- data.frame(
  treat = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6),
  female = c(1, 0, 1, 0, 0, 1)
)
r <- wwc_robustness(df, treatment = "treat")
r
#>   covariate       type category_default    categories flips abs_es_min
#> 1   pretest continuous    not_satisfied not_satisfied FALSE  0.8000000
#> 2    female     binary    not_satisfied not_satisfied FALSE  0.8401784
#>   abs_es_max
#> 1  1.0000000
#> 2  0.8401784
attr(r, "overall")
#>      sd_type correction       overall
#> 1     pooled       TRUE not_satisfied
#> 2 comparison       TRUE not_satisfied
#> 3     pooled      FALSE not_satisfied
#> 4 comparison      FALSE not_satisfied
```
