# Cox index for a binary covariate

Computes the What Works Clearinghouse (WWC) Cox index, a standardized
effect size for a binary (dichotomous) covariate. The Cox index places
the difference between two proportions on a scale comparable to Hedges'
g, so it can be classified with the same baseline-equivalence
thresholds.

## Usage

``` r
cox_index(x, treatment, na.rm = TRUE)
```

## Arguments

- x:

  A binary covariate (numeric `0/1`, logical, two-level factor, or any
  vector with exactly two unique non-missing values). The larger value
  (e.g. `1`, `TRUE`, or the second sorted level) is treated as the
  "event".

- treatment:

  Vector the same length as `x` identifying group membership; exactly
  two unique non-missing values (see
  [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md)).

- na.rm:

  Logical; drop rows where `x` or `treatment` is `NA`. Default `TRUE`.

## Value

A single numeric value: the Cox index. Returns `NA` (with a warning)
when a group proportion is exactly 0 or 1, where the index is undefined.

## Details

The index is \\d\_{Cox} = (\mathrm{logit}(p_t) - \mathrm{logit}(p_c)) /
1.65\\, where \\p_t\\ and \\p_c\\ are the proportions in the "event"
category for the treatment and comparison groups.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

## Examples

``` r
x <- c(1, 1, 1, 1, 0, 1, 0, 0)
g <- c(1, 1, 1, 1, 0, 0, 0, 0)
cox_index(x, g)
#> Warning: Cox index is undefined when a group proportion is 0 or 1; returning NA.
#> [1] NA
```
