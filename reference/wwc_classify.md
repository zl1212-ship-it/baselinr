# Classify baseline equivalence under WWC standards

Maps standardized mean differences to the three What Works Clearinghouse
baseline-equivalence categories. Sign is ignored; classification uses
the absolute value of the effect size.

## Usage

``` r
wwc_classify(es)
```

## Arguments

- es:

  Numeric vector of standardized mean differences (e.g. values returned
  by
  [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md)).

## Value

A character vector the same length as `es`:

- `"satisfied"` when `|es| <= 0.05` (no adjustment needed),

- `"satisfied_with_adjustment"` when `0.05 < |es| <= 0.25` (equivalence
  holds only if the covariate is adjusted for in the impact model),

- `"not_satisfied"` when `|es| > 0.25`.

`NA` inputs return `NA`.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

## Examples

``` r
wwc_classify(c(0.03, 0.12, 0.80))
#> [1] "satisfied"                 "satisfied_with_adjustment"
#> [3] "not_satisfied"            
```
