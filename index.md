# baselinr

`baselinr` builds report-ready **baseline equivalence** tables for
impact evaluations in education research, following the conventions of
the [What Works Clearinghouse (WWC)](https://ies.ed.gov/ncee/wwc/). It
does one thing well: given a treatment indicator and a set of continuous
covariates, it reports the standardized mean difference (Hedges’ g) and
the WWC equivalence category for each covariate.

It is a thin, education-specific reporting layer. For general-purpose
covariate balance assessment, see
[`cobalt`](https://ngreifer.github.io/cobalt/); `baselinr` focuses
narrowly on the WWC equivalence categories that education evaluation
reports are required to state.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("zl1212-ship-it/baselinr")
```

## Example

``` r

library(baselinr)

study <- data.frame(
  treat = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6)
)

baseline_equivalence(study, treatment = "treat")
#>   covariate n_treatment n_comparison mean_treatment mean_comparison
#> 1   pretest           3            3              6               5
#>   sd_treatment sd_comparison hedges_g  wwc_category
#> 1            1             1      0.8 not_satisfied
```

The WWC categories are:

| Hedges’ g (absolute) | Category | Meaning |
|----|----|----|
| `<= 0.05` | `satisfied` | Baseline equivalence holds. |
| `0.05`–`0.25` | `satisfied_with_adjustment` | Holds only if the covariate is adjusted for in the impact model. |
| `> 0.25` | `not_satisfied` | Cannot establish equivalence. |

## Scope

Version 0.1.0 supports continuous covariates. Binary covariates (via the
WWC Cox index), formatted report output, and a Love plot are on the
roadmap — see `NEWS.md`.

## License

MIT © baselinr authors
