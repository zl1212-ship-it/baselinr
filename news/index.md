# Changelog

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

### Roadmap

- Binary covariates via the WWC Cox index.
- Formatted output for reports (`gt` / `flextable`).
- Love plot of standardized mean differences across covariates.
