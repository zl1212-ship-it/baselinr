# baselinr 0.2.0

* New `cox_index()`: WWC Cox index standardized effect size for binary
  (dichotomous) covariates.
* `baseline_equivalence()` now handles **binary covariates** (numeric `0/1`,
  logical, or two-level factor) via the Cox index, in addition to continuous
  covariates via Hedges' g. A covariate with exactly two unique values is
  treated as binary.
* The output gains a `type` column (`"continuous"` / `"binary"`), and the
  effect-size column is renamed from `hedges_g` to the estimator-agnostic
  `effect_size` (**breaking change**). For binary covariates, `mean_treatment`
  and `mean_comparison` report event proportions.
* The default covariate set now includes logical and factor columns, not only
  numeric ones.

## Roadmap

* Formatted output for reports (`gt` / `flextable`).
* Love plot of standardized effect sizes across covariates.

# baselinr 0.1.0

Initial scaffold.

* `hedges_g()`: standardized mean difference (Hedges' g) between a treatment
  and a comparison group, with the WWC small-sample correction factor.
* `wwc_classify()`: classify standardized mean differences into the three WWC
  baseline-equivalence categories.
* `baseline_equivalence()`: build a report-ready baseline equivalence table for
  continuous covariates.
