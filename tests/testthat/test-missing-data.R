test_that("pairwise default reproduces the previous behavior exactly", {
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    pretest = c(5, 6, 7, NA, 4, 5, 6, NA),
    female = c(1, 0, 1, 0, 0, 1, 0, 1)
  )
  res <- baseline_equivalence(df, "treat")
  expect_identical(res, baseline_equivalence(df, "treat", missing = "pairwise"))
  expect_false("missing_treatment" %in% names(res))
  # pretest drops its two NA cases; female keeps all eight
  expect_equal(res$n_treatment[res$covariate == "pretest"], 3L)
  expect_equal(res$n_comparison[res$covariate == "pretest"], 3L)
  expect_equal(res$n_treatment[res$covariate == "female"], 4L)
})

test_that("missing = 'complete' restricts every row to the common sample", {
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    pretest = c(5, 6, 7, NA, 4, 5, 6, NA),
    female = c(1, 0, 1, 0, 0, 1, 0, 1)
  )
  res <- baseline_equivalence(df, "treat", missing = "complete")
  expect_equal(res$n_treatment, c(3L, 3L))
  expect_equal(res$n_comparison, c(3L, 3L))
  # identical to running the table on the complete-case subset directly
  cc <- df[stats::complete.cases(df), ]
  expect_equal(res$effect_size, baseline_equivalence(cc, "treat")$effect_size)
})

test_that("report_missing adds per-group rates computed before deletion", {
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    pretest = c(5, 6, 7, NA, 4, 5, 6, NA),
    female = c(1, 0, 1, 0, 0, 1, 0, 1)
  )
  res <- baseline_equivalence(df, "treat", report_missing = TRUE)
  expect_equal(
    names(res)[1:6],
    c(
      "covariate", "type", "n_treatment", "n_comparison",
      "missing_treatment", "missing_comparison"
    )
  )
  pre <- res[res$covariate == "pretest", ]
  expect_equal(pre$missing_treatment, 0.25)
  expect_equal(pre$missing_comparison, 0.25)
  expect_equal(res$missing_treatment[res$covariate == "female"], 0)
  # the rates describe the data as collected, under either deletion rule
  cmp <- baseline_equivalence(df, "treat",
    missing = "complete", report_missing = TRUE
  )
  expect_equal(cmp$missing_treatment, res$missing_treatment)
  expect_equal(cmp$missing_comparison, res$missing_comparison)
})

test_that("missingness denominators exclude cases with a missing treatment", {
  df <- data.frame(
    treat = c(1, 1, 1, NA, 0, 0, 0),
    pretest = c(5, 6, NA, 4, 4, 5, 6)
  )
  res <- baseline_equivalence(df, "treat", report_missing = TRUE)
  expect_equal(res$missing_treatment, 1 / 3)
  expect_equal(res$missing_comparison, 0)
})

test_that("missing = 'complete' errors when a group loses too many cases", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    a = c(1, NA, NA, 4, 5, 6),
    b = c(NA, 2, 3, 4, 5, 6)
  )
  expect_error(
    baseline_equivalence(df, "treat", missing = "complete"),
    "complete cases"
  )
  # the message reports the per-group counts and how to diagnose the loss
  expect_error(
    baseline_equivalence(df, "treat", missing = "complete"),
    "treatment: 0, comparison: 3"
  )
})

test_that("a covariate collapsed by complete-case deletion is named", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0, 1, 0),
    female = factor(c("f", "f", "f", "f", "f", "f", "m", "m")),
    pretest = c(5, 6, 7, 4, 5, 6, NA, NA)
  )
  # pairwise handles this data; complete collapses female to one value
  expect_silent(baseline_equivalence(df, "treat"))
  expect_error(
    baseline_equivalence(df, "treat", missing = "complete"),
    "'female' has a single observed value"
  )
  # same collapse with a numeric 0/1 covariate
  df$female <- c(1, 1, 1, 1, 1, 1, 0, 0)
  expect_error(
    baseline_equivalence(df, "treat", missing = "complete"),
    "'female' has a single observed value"
  )
})

test_that("baseline_equivalence rejects an unknown `missing` option", {
  df <- data.frame(treat = c(1, 1, 0, 0), x = c(1, 2, 3, 4))
  expect_error(baseline_equivalence(df, "treat", missing = "impute"))
})

test_that("gt_baseline formats a table that includes missingness columns", {
  skip_if_not_installed("gt")
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    pretest = c(5, 6, 7, NA, 4, 5, 6, NA)
  )
  tbl <- gt_baseline(baseline_equivalence(df, "treat", report_missing = TRUE))
  expect_s3_class(tbl, "gt_tbl")
})
