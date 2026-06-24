test_that("hedges_g matches a hand-computed value", {
  x <- c(5, 6, 7, 4, 5, 6)
  g <- c(1, 1, 1, 0, 0, 0)
  # Cohen's d = 1; correction = 1 - 3/(4*6-9) = 0.8; Hedges' g = 0.8
  expect_equal(hedges_g(x, g), 0.8)
})

test_that("hedges_g is signed by (treatment - comparison)", {
  x <- c(4, 5, 6, 5, 6, 7) # treatment group is lower
  g <- c(1, 1, 1, 0, 0, 0)
  expect_equal(hedges_g(x, g), -0.8)
})

test_that("hedges_g works with logical and factor treatments", {
  x <- c(5, 6, 7, 4, 5, 6)
  expect_equal(hedges_g(x, c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)), 0.8)
  expect_equal(
    hedges_g(x, factor(c("t", "t", "t", "c", "c", "c"))),
    0.8
  )
})

test_that("hedges_g drops NA rows by default", {
  x <- c(5, 6, 7, NA, 4, 5, 6)
  g <- c(1, 1, 1, 1, 0, 0, 0)
  expect_equal(hedges_g(x, g), 0.8)
})

test_that("hedges_g validates its inputs", {
  expect_error(hedges_g(letters[1:6], c(1, 1, 1, 0, 0, 0)), "numeric")
  expect_error(hedges_g(1:3, c(1, 0)), "same length")
  expect_error(hedges_g(1:4, c(1, 1, 1, 1)), "exactly two")
  expect_error(hedges_g(c(1, 5, 2, 3), c(1, 1, 0, 0)), NA) # no error
})

test_that("wwc_classify maps thresholds correctly", {
  expect_equal(
    wwc_classify(c(0.03, 0.05, 0.10, 0.25, 0.80, -0.10)),
    c(
      "satisfied", "satisfied", "satisfied_with_adjustment",
      "satisfied_with_adjustment", "not_satisfied",
      "satisfied_with_adjustment"
    )
  )
  expect_true(is.na(wwc_classify(NA_real_)))
  expect_error(wwc_classify("a"), "numeric")
})

test_that("baseline_equivalence returns one row per covariate", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6)
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)
  expect_equal(res$covariate, "pretest")
  expect_equal(res$n_treatment, 3L)
  expect_equal(res$n_comparison, 3L)
  expect_equal(res$mean_treatment, 6)
  expect_equal(res$hedges_g, 0.8)
  expect_equal(res$wwc_category, "not_satisfied")
})

test_that("baseline_equivalence defaults to all numeric covariates", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    age = c(10, 11, 12, 10, 11, 12),
    site = c("a", "a", "b", "b", "a", "b")
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_setequal(res$covariate, c("pretest", "age"))
})

test_that("baseline_equivalence validates its inputs", {
  df <- data.frame(treat = c(1, 1, 0, 0), grp = c("a", "b", "a", "b"))
  expect_error(baseline_equivalence(df, "treat", covariates = "grp"), "numeric")
  expect_error(baseline_equivalence(df, "missing"), "not found")
  expect_error(baseline_equivalence(as.list(df), "treat"), "data frame")
  one_level <- data.frame(treat = c(1, 1, 1), x = c(1, 2, 3))
  expect_error(baseline_equivalence(one_level, "treat"), "exactly two")
})
