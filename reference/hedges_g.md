# Hedges' g standardized mean difference

Computes the standardized mean difference (Hedges' g) between a
treatment and a comparison group for a single numeric covariate, using
the pooled within-group standard deviation and the small-sample
correction factor used by the What Works Clearinghouse (WWC).

## Usage

``` r
hedges_g(x, treatment, na.rm = TRUE)
```

## Arguments

- x:

  Numeric vector of covariate values.

- treatment:

  Vector the same length as `x` identifying group membership. Must have
  exactly two unique non-missing values. The larger value (e.g. `1`,
  `TRUE`, or the second sorted level) is treated as the treatment group;
  the other as the comparison group.

- na.rm:

  Logical; drop rows where `x` or `treatment` is `NA`. Default `TRUE`.

## Value

A single numeric value: Hedges' g. Positive when the treatment group
mean exceeds the comparison group mean.

## Details

The correction factor is \\\omega = 1 - 3 / (4N - 9)\\, where \\N =
n\_{treatment} + n\_{comparison}\\.

## References

What Works Clearinghouse (2022). *Procedures Handbook* (Version 5.0).
U.S. Department of Education.

## Examples

``` r
x <- c(5, 6, 7, 4, 5, 6)
g <- c(1, 1, 1, 0, 0, 0)
hedges_g(x, g) # 0.8
#> [1] 0.8
```
