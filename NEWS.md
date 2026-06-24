# baselinr 0.1.0

Initial scaffold.

* `hedges_g()`: standardized mean difference (Hedges' g) between a treatment
  and a comparison group, with the WWC small-sample correction factor.
* `wwc_classify()`: classify standardized mean differences into the three WWC
  baseline-equivalence categories.
* `baseline_equivalence()`: build a report-ready baseline equivalence table for
  continuous covariates.

## Roadmap

* Binary covariates via the WWC Cox index.
* Formatted output for reports (`gt` / `flextable`).
* Love plot of standardized mean differences across covariates.
