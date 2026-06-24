---
title: 'baselinr: WWC-aligned baseline equivalence tables for education impact evaluations'
tags:
  - R
  - education research
  - program evaluation
  - causal inference
  - What Works Clearinghouse
  - effect size
authors:
  - name: Yuxia Liang
    orcid: 0009-0008-6489-3836
    affiliation: 1
affiliations:
  - name: University of Washington, Seattle
    index: 1
date: 24 June 2026
bibliography: paper.bib
---

# Summary

In quasi-experimental and randomized impact evaluations of education programs,
analysts must demonstrate that treatment and comparison groups were similar at
baseline before any claim about program effects is credible. In U.S. education
research, the What Works Clearinghouse (WWC) sets the de facto standard for
this judgment: each baseline covariate is summarized by a standardized mean
difference (Hedges' g) and classified into one of three categories that
determine whether and how the covariate must be handled in the impact model
[@wwc2022]. `baselinr` is a small R package that automates this specific,
repetitive task. Given a data frame, a treatment indicator, and a set of
covariates, it returns a report-ready table containing each group's sample size
and summary statistics; the appropriate standardized effect size — Hedges' g
(with the WWC small-sample correction) for continuous covariates and the Cox
index for binary covariates; and the corresponding WWC baseline-equivalence
category.

# Statement of need

Assessing baseline equivalence to WWC conventions is routine but error-prone
hand-work: analysts repeatedly compute Hedges' g with the small-sample
correction factor, apply the 0.05 and 0.25 thresholds, and assemble a table for
every report, often in spreadsheet software or ad hoc scripts. General-purpose
R tools for covariate balance, such as `cobalt` [@greifer2023], compute a wide
range of balance statistics for matching and weighting workflows but do not
encode the specific WWC reporting categories that education evaluation reports
are required to state. `baselinr` deliberately occupies the narrow gap above
those tools: it is a thin, education-specific reporting layer that produces the
exact baseline-equivalence categorization expected in WWC-aligned reporting,
with no modeling assumptions and a minimal interface. The intended users are
applied education researchers, evaluators, and graduate students who need a
reproducible, transparent baseline table rather than a general causal-inference
framework.

# Key features

- `hedges_g()` computes the standardized mean difference between a treatment
  and a comparison group for a continuous covariate, using the pooled
  within-group standard deviation and the small-sample correction factor
  $\omega = 1 - 3 / (4N - 9)$, where $N$ is the combined sample size
  [@hedges1981].
- `cox_index()` computes the WWC Cox index for a binary covariate,
  $d_{Cox} = (\mathrm{logit}(p_t) - \mathrm{logit}(p_c)) / 1.65$, placing a
  difference in proportions on a scale comparable to Hedges' g [@wwc2022].
- `wwc_classify()` maps standardized effect sizes to the three WWC categories:
  `satisfied` ($|es| \le 0.05$), `satisfied_with_adjustment`
  ($0.05 < |es| \le 0.25$), and `not_satisfied` ($|es| > 0.25$) [@wwc2022].
- `baseline_equivalence()` combines these into a one-row-per-covariate table of
  group sizes, summary statistics, the appropriate effect size, and WWC
  category, choosing Hedges' g or the Cox index based on whether each covariate
  is continuous or binary.
- `love_plot()` and `gt_baseline()` present that table as a Love plot of
  standardized effect sizes (with WWC threshold lines) and as a formatted `gt`
  table, respectively.
- `wwc_summary()` collapses the table into an overall equivalence verdict, and
  `attrition()` reports overall and differential attrition — the inputs to the
  WWC attrition standard — so the package covers both pillars of WWC group-design
  quality.

The package depends only on base R [@rcoreteam], is covered by unit tests, and
ships with a worked example in its vignette.

# Example

```r
library(baselinr)

study <- data.frame(
  treat   = c(1, 1, 1, 0, 0, 0),
  pretest = c(5, 6, 7, 4, 5, 6), # continuous -> Hedges' g
  female  = c(1, 0, 1, 0, 0, 1)  # binary     -> Cox index
)

baseline_equivalence(study, treatment = "treat")
#>   covariate       type n_treatment n_comparison mean_treatment mean_comparison
#> 1   pretest continuous           3            3      6.0000000       5.0000000
#> 2    female     binary           3            3      0.6666667       0.3333333
#>   sd_treatment sd_comparison effect_size  wwc_category
#> 1    1.0000000     1.0000000   0.8000000 not_satisfied
#> 2    0.5773503     0.5773503   0.8401784 not_satisfied
```

# Scope and limitations

`baselinr` handles continuous covariates (Hedges' g) and binary covariates
(the Cox index), and presents results as a Love plot (`love_plot()`) or a
formatted `gt` table (`gt_baseline()`). `baselinr` reports baseline-equivalence
statistics; it does not select covariates, fit impact models, or make adequacy
determinations on the user's behalf.

# References
