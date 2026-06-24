# Changelog

## baselinr 0.3.0

- New
  [`love_plot()`](https://zl1212-ship-it.github.io/baselinr/reference/love_plot.md):
  a Love plot of standardized effect sizes across covariates, with WWC
  threshold reference lines and points coloured by category (requires
  `ggplot2`).
- New
  [`gt_baseline()`](https://zl1212-ship-it.github.io/baselinr/reference/gt_baseline.md):
  render a baseline equivalence table as a formatted `gt` table with
  readable labels and rounded statistics (requires `gt`).
- `ggplot2` and `gt` added to Suggests; both functions error gracefully
  if the package is not installed.

## baselinr 0.2.0

- New
  [`cox_index()`](https://zl1212-ship-it.github.io/baselinr/reference/cox_index.md):
  WWC Cox index standardized effect size for binary (dichotomous)
  covariates.
- [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md)
  now handles **binary covariates** (numeric `0/1`, logical, or
  two-level factor) via the Cox index, in addition to continuous
  covariates via Hedges’ g. A covariate with exactly two unique values
  is treated as binary.
- The output gains a `type` column (`"continuous"` / `"binary"`), and
  the effect-size column is renamed from `hedges_g` to the
  estimator-agnostic `effect_size` (**breaking change**). For binary
  covariates, `mean_treatment` and `mean_comparison` report event
  proportions.
- The default covariate set now includes logical and factor columns, not
  only numeric ones.

### Roadmap

- Formatted output for reports (`gt` / `flextable`).
- Love plot of standardized effect sizes across covariates.

## baselinr 0.1.0

Initial scaffold.

- [`hedges_g()`](https://zl1212-ship-it.github.io/baselinr/reference/hedges_g.md):
  standardized mean difference (Hedges’ g) between a treatment and a
  comparison group, with the WWC small-sample correction factor.
- [`wwc_classify()`](https://zl1212-ship-it.github.io/baselinr/reference/wwc_classify.md):
  classify standardized mean differences into the three WWC
  baseline-equivalence categories.
- [`baseline_equivalence()`](https://zl1212-ship-it.github.io/baselinr/reference/baseline_equivalence.md):
  build a report-ready baseline equivalence table for continuous
  covariates.
