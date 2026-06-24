# Summary

In quasi-experimental and randomized impact evaluations of education
programs, analysts must demonstrate that treatment and comparison groups
were similar at baseline before any claim about program effects is
credible. In U.S. education research, the What Works Clearinghouse (WWC)
sets the de facto standard for this judgment: each baseline covariate is
summarized by a standardized mean difference (Hedges’ g) and classified
into one of three categories that determine whether and how the
covariate must be handled in the impact model \[@wwc2022\]. `baselinr`
is a small R package that automates this specific, repetitive task.
Given a data frame, a treatment indicator, and a set of continuous
covariates, it returns a report-ready table containing each group’s
sample size, mean, and standard deviation; the standardized mean
difference with the WWC small-sample correction; and the corresponding
WWC baseline-equivalence category.

# Statement of need

Assessing baseline equivalence to WWC conventions is routine but
error-prone hand-work: analysts repeatedly compute Hedges’ g with the
small-sample correction factor, apply the 0.05 and 0.25 thresholds, and
assemble a table for every report, often in spreadsheet software or ad
hoc scripts. General-purpose R tools for covariate balance, such as
`cobalt` \[@greifer2023\], compute a wide range of balance statistics
for matching and weighting workflows but do not encode the specific WWC
reporting categories that education evaluation reports are required to
state. `baselinr` deliberately occupies the narrow gap above those
tools: it is a thin, education-specific reporting layer that produces
the exact baseline-equivalence categorization expected in WWC-aligned
reporting, with no modeling assumptions and a minimal interface. The
intended users are applied education researchers, evaluators, and
graduate students who need a reproducible, transparent baseline table
rather than a general causal-inference framework.

# Key features

- [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md)
  computes the standardized mean difference between a treatment and a
  comparison group for a single continuous covariate, using the pooled
  within-group standard deviation and the small-sample correction factor
  $`\omega = 1 - 3 / (4N - 9)`$, where $`N`$ is the combined sample size
  \[@hedges1981\].
- [`wwc_classify()`](https://zl1212-ship-it.github.io/baselinr/reference/wwc_classify.md)
  maps standardized mean differences to the three WWC categories:
  `satisfied` ($`|g| \le 0.05`$), `satisfied_with_adjustment`
  ($`0.05 < |g| \le 0.25`$), and `not_satisfied` ($`|g| > 0.25`$)
  \[@wwc2022\].
- [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md)
  combines these into a one-row-per-covariate table of group sizes,
  means, standard deviations, Hedges’ g, and WWC category.

The package depends only on base R \[@rcoreteam\], is covered by unit
tests, and ships with a worked example in its vignette.

# Example

``` r

library(baselinr)

study <- data.frame(
  treat   = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6)
)

baseline_equivalence(study, treatment = "treat")
#>   covariate n_treatment n_comparison mean_treatment mean_comparison
#> 1   pretest           3            3              6               5
#>   sd_treatment sd_comparison hedges_g  wwc_category
#> 1            1             1      0.8 not_satisfied
```

# Scope and limitations

Version 0.1.0 handles continuous covariates. Binary covariates (via the
WWC Cox index), formatted report output, and a Love plot of standardized
mean differences across covariates are planned. `baselinr` reports
baseline-equivalence statistics; it does not select covariates, fit
impact models, or make adequacy determinations on the user’s behalf.

# Acknowledgements

# References
