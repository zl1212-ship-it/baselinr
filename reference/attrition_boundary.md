# Classify a study under the WWC attrition standard

Given a study's overall and differential attrition, classifies it as low
or high attrition against the What Works Clearinghouse (WWC) attrition
boundary (Standards Handbook Version 4.1, Table II.1). This is the
classification that
[`attrition()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition.md)
deliberately leaves to the user:
[`attrition()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition.md)
reports the rates, `attrition_boundary()` applies the standard.

## Usage

``` r
attrition_boundary(
  overall,
  differential,
  assumption = c("cautious", "optimistic")
)
```

## Arguments

- overall:

  Overall attrition, as a proportion in `[0, 1]` (as returned by
  [`attrition()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition.md)).

- differential:

  Differential attrition, as a proportion (the absolute difference in
  group attrition rates, as returned by
  [`attrition()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition.md)).

- assumption:

  Which boundary to apply: `"cautious"` (default) or `"optimistic"`.

## Value

A data frame, one row per input, with columns `overall`, `differential`,
`assumption`, `max_differential` (the highest differential attrition
still counted as low, as a proportion; `NA` where the overall rate is
beyond the boundary), and `attrition` (`"low"` or `"high"`).

## Details

The WWC uses one of two boundaries. The **cautious** boundary is applied
when the intervention could plausibly affect attrition (for example, a
dropout prevention program); the **optimistic** boundary when it is
unlikely to (for example, a first-grade reading program). The applicable
boundary is set by the review protocol, not chosen post hoc; the default
here is the more conservative cautious boundary.

## References

What Works Clearinghouse (2020). *Standards Handbook, Version 4.1*,
Table II.1. U.S. Department of Education.

## Examples

``` r
# A study with 8% overall and 3 percentage-point differential attrition:
attrition_boundary(0.08, 0.03) # low under the cautious boundary
#>   overall differential assumption max_differential attrition
#> 1    0.08         0.03   cautious            0.063       low

# 30% overall, 6-point differential: high if cautious, low if optimistic
attrition_boundary(0.30, 0.06, "cautious")
#>   overall differential assumption max_differential attrition
#> 1     0.3         0.06   cautious            0.041      high
attrition_boundary(0.30, 0.06, "optimistic")
#>   overall differential assumption max_differential attrition
#> 1     0.3         0.06 optimistic            0.082       low

# Chained from attrition():
set.seed(1)
g <- rep(c(1, 0), each = 100)
kept <- rbinom(200, 1, ifelse(g == 1, 0.9, 0.82))
a <- attrition(g, kept)
attrition_boundary(a$attrition_overall, a$differential_attrition)
#>   overall differential assumption max_differential attrition
#> 1    0.12         0.12   cautious            0.062      high
```
