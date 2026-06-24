# Overall and differential attrition

Computes overall and differential sample attrition for a two-group
design, the inputs to the What Works Clearinghouse (WWC) attrition
standard. Differential attrition is the absolute difference between the
treatment and comparison attrition rates.

## Usage

``` r
attrition(treatment, retained, na.rm = TRUE)
```

## Arguments

- treatment:

  Vector identifying group membership; exactly two unique non-missing
  values (the larger is treated as the treatment group, as in
  [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md)).

- retained:

  Logical (or `0/1`) the same length as `treatment`: `TRUE`/`1` for
  cases retained in the analytic sample, `FALSE`/`0` for those lost.

- na.rm:

  Logical; drop rows where `treatment` or `retained` is `NA`. Default
  `TRUE`.

## Value

A one-row data frame with columns `attrition_overall`,
`attrition_treatment`, `attrition_comparison`, and
`differential_attrition` (all proportions).

## Details

This function reports the attrition rates; it does not classify them.
Compare the overall and differential rates against the WWC attrition
boundary for your chosen response assumption (cautious or optimistic) in
the Procedures Handbook.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

## Examples

``` r
set.seed(1)
g <- rep(c(1, 0), each = 100)
kept <- rbinom(200, 1, ifelse(g == 1, 0.9, 0.8))
attrition(g, kept)
#>   attrition_overall attrition_treatment attrition_comparison
#> 1              0.12                0.06                 0.18
#>   differential_attrition
#> 1                   0.12
```
