# baselinr 0.5.0

* New `wwc_summary()`: collapse a `baseline_equivalence()` table into an overall
  WWC verdict (`satisfied` / `satisfied_with_adjustment` / `not_satisfied`) plus
  per-category counts and the largest absolute effect size.
* New `attrition()`: overall and differential attrition for a two-group design —
  the inputs to the WWC attrition standard.

# baselinr 0.4.0

* New bundled dataset `tutoring`: a simulated quasi-experimental tutoring
  evaluation (400 students) whose covariates span all three WWC equivalence
  categories. See `data-raw/tutoring.R` for how it is generated.
* New vignette "An impact-evaluation workflow" walking from raw study data to a
  baseline-equivalence report, Love plot, and formatted table.

# baselinr 0.3.0

* New `love_plot()`: a Love plot of standardized effect sizes across covariates,
  with WWC threshold reference lines and points coloured by category (requires
  `ggplot2`).
* New `gt_baseline()`: render a baseline equivalence table as a formatted `gt`
  table with readable labels and rounded statistics (requires `gt`).
* `ggplot2` and `gt` added to Suggests; both functions error gracefully if the
  package is not installed.

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
