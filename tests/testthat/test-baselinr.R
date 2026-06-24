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
  expect_equal(hedges_g(x, factor(c("t", "t", "t", "c", "c", "c"))), 0.8)
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

test_that("cox_index matches a hand-computed value", {
  x <- c(rep(1, 8), rep(0, 2), rep(1, 5), rep(0, 5)) # p_t = 0.8, p_c = 0.5
  g <- c(rep(1, 10), rep(0, 10))
  expect_equal(cox_index(x, g), (qlogis(0.8) - qlogis(0.5)) / 1.65)
})

test_that("cox_index handles logical and factor binaries", {
  x_log <- c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
  g <- c(1, 1, 1, 1, 0, 0, 0, 0) # p_t = 1.0 -> undefined
  expect_warning(r <- cox_index(x_log, g))
  expect_true(is.na(r))
})

test_that("cox_index returns NA (with warning) at a 0/1 proportion", {
  x <- c(1, 1, 1, 1, 0, 0, 0, 1)
  g <- c(1, 1, 1, 1, 0, 0, 0, 0) # p_t = 1
  expect_warning(r <- cox_index(x, g), "undefined")
  expect_true(is.na(r))
})

test_that("cox_index validates its inputs", {
  expect_error(cox_index(c(1, 2, 3, 1, 2, 3), c(1, 1, 1, 0, 0, 0)), "binary")
  expect_error(cox_index(1:3, c(1, 0)), "same length")
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

test_that("baseline_equivalence handles a continuous covariate", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6)
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)
  expect_equal(res$covariate, "pretest")
  expect_equal(res$type, "continuous")
  expect_equal(res$n_treatment, 3L)
  expect_equal(res$mean_treatment, 6)
  expect_equal(res$effect_size, 0.8)
  expect_equal(res$wwc_category, "not_satisfied")
})

test_that("baseline_equivalence handles a binary covariate via Cox index", {
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    female = c(1, 1, 0, 0, 1, 0, 0, 0) # p_t = 0.5, p_c = 0.25
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_equal(res$type, "binary")
  expect_equal(res$mean_treatment, 0.5)
  expect_equal(res$mean_comparison, 0.25)
  expect_equal(res$effect_size, (qlogis(0.5) - qlogis(0.25)) / 1.65)
  expect_equal(res$wwc_category, "not_satisfied")
})

test_that("baseline_equivalence mixes continuous and binary covariates", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_equal(nrow(res), 2L)
  expect_setequal(res$covariate, c("pretest", "female"))
  expect_equal(res$type[res$covariate == "pretest"], "continuous")
  expect_equal(res$type[res$covariate == "female"], "binary")
})

test_that("baseline_equivalence default picks numeric, logical, and factor cols", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    x = c(5, 6, 7, 4, 5, 6),
    flag = c(TRUE, TRUE, FALSE, FALSE, TRUE, FALSE),
    grp = factor(c("a", "b", "a", "b", "a", "b")),
    id = c("p1", "p2", "p3", "p4", "p5", "p6"),
    stringsAsFactors = FALSE
  )
  res <- baseline_equivalence(df, treatment = "treat")
  expect_setequal(res$covariate, c("x", "flag", "grp")) # character `id` excluded
})

test_that("baseline_equivalence validates its inputs", {
  df <- data.frame(treat = c(1, 1, 0, 0), site = c("a", "b", "c", "a"))
  expect_error(
    baseline_equivalence(df, "treat", covariates = "site"),
    "not supported"
  )
  expect_error(baseline_equivalence(df, "missing"), "not found")
  expect_error(baseline_equivalence(as.list(df), "treat"), "data frame")
  one_level <- data.frame(treat = c(1, 1, 1), x = c(1, 2, 3))
  expect_error(baseline_equivalence(one_level, "treat"), "exactly two")
})
