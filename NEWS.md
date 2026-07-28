# baselinr 0.6.0

* New `wwc_robustness()`: reports how stable a baseline-equivalence verdict is to
  the computation choices an analyst could defensibly make differently
  (standardizing by the pooled versus the comparison-group standard deviation,
  and applying the WWC small-sample correction or not), flagging whether each
  covariate's category, and the overall verdict, changes. A multiverse view of a
  single WWC determination.
* New `attrition_boundary()`: classifies a study as low or high attrition against
  the WWC attrition boundary (Standards Handbook v4.1, Table II.1), under the
  cautious or optimistic assumption. Complements `attrition()`, which reports the
  rates but leaves the classification to the user.
* New `wwc_rating()`: applies the WWC group-design rating logic (Standards
  Handbook v4.1, Section II) to attrition and baseline equivalence, returning
  "Meets Without Reservations", "Meets With Reservations", or "Does Not Meet".
* New `cluster_correction()`: the WWC clustering correction for mismatched
  analyses (Procedures Handbook v4.1, Appendix F, after Hedges 2007). Corrects
  the t statistic and its degrees of freedom for clustering and returns the
  clustering-corrected p value and significance decision, with the WWC default
  ICCs (0.20 achievement, 0.10 other). Validated against 1,800+ clustered
  findings in the official WWC study database.
* Documented that `cox_index()` follows Procedures Handbook v4.1 [VI.1.2] exactly:
  the Cox index carries no small-sample correction (that correction applies to
  Hedges' g only).
* `hedges_g()` and `cox_index()` now handle missing values consistently when
  `na.rm = FALSE`: both reject missing input up front with the message
  "Missing values present; set `na.rm = TRUE` to drop them." Previously
  `hedges_g()` raised an opaque internal error while `cox_index()` silently
  returned `NA` (#12).

# baselinr 0.5.0

* New `wwc_summary()`: collapse a `baseline_equivalence()` table into an overall
  WWC verdict (`satisfied` / `satisfied_with_adjustment` / `not_satisfied`) plus
  per-category counts and the largest absolute effect size.
* New `attrition()`: overall and differential attrition for a two-group design,
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
