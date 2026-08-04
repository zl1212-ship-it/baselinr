# WWC group-design study rating

Applies the What Works Clearinghouse (WWC) group-design rating logic to
the two determinations this package supports, sample attrition and
baseline equivalence, and returns the study's rating. This encodes the
main decision path of the WWC Standards Handbook (Version 4.1, Section
II): a randomized controlled trial (RCT) with low attrition can meet
standards without reservations; an RCT with high attrition is held to
the same baseline requirement as a quasi-experimental design (QED); and
a QED, or a high attrition RCT, meets standards with reservations only
if baseline equivalence is established, and otherwise does not meet
standards.

## Usage

``` r
wwc_rating(design, baseline, attrition = NULL)
```

## Arguments

- design:

  `"rct"` or `"qed"`.

- baseline:

  The overall baseline-equivalence verdict, one of `"satisfied"`,
  `"satisfied_with_adjustment"`, or `"not_satisfied"` (the `overall`
  value from
  [`wwc_summary()`](https://zl1212-ship-it.github.io/baselinr/reference/wwc_summary.md)).

- attrition:

  For an RCT, `"low"` or `"high"` (the `attrition` value from
  [`attrition_boundary()`](https://zl1212-ship-it.github.io/baselinr/reference/attrition_boundary.md));
  required for `design = "rct"`, ignored for a QED.

## Value

A length-one character string: one of
`"Meets WWC Group Design Standards Without Reservations"`,
`"Meets WWC Group Design Standards With Reservations"`, or
`"Does Not Meet WWC Group Design Standards"`. The reasoning is attached
as `attr(x, "basis")`.

## Details

This function covers the attrition-and-equivalence path only. A real WWC
review also checks that random assignment was not compromised, that
there are no confounding factors, and that the required baseline
measures were used; those judgments are the reviewer's and are assumed
satisfied here.

## References

What Works Clearinghouse (2020). *Standards Handbook, Version 4.1*,
Section II. U.S. Department of Education.

## Examples

``` r
# Low-attrition RCT: meets without reservations regardless of baseline.
wwc_rating("rct", baseline = "not_satisfied", attrition = "low")
#> [1] "Meets WWC Group Design Standards Without Reservations"
#> attr(,"basis")
#> [1] "RCT with low attrition: random assignment establishes equivalence, so the study can meet standards without reservations."

# High-attrition RCT hinges on baseline equivalence, like a QED.
wwc_rating("rct", baseline = "satisfied_with_adjustment", attrition = "high")
#> [1] "Meets WWC Group Design Standards With Reservations"
#> attr(,"basis")
#> [1] "RCT with high attrition is held to the QED baseline requirement; baseline equivalence is established, so it meets with reservations."

# QED that fails baseline equivalence does not meet standards.
wwc_rating("qed", baseline = "not_satisfied")
#> [1] "Does Not Meet WWC Group Design Standards"
#> attr(,"basis")
#> [1] "QED cannot meet without reservations; baseline equivalence is not established, so it does not meet standards."
```
