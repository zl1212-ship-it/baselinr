test_that("wwc_summary computes the overall verdict and counts", {
  eq <- data.frame(
    covariate = c("a", "b", "c"),
    effect_size = c(0.02, 0.10, -0.30),
    wwc_category = c("satisfied", "satisfied_with_adjustment", "not_satisfied")
  )
  s <- wwc_summary(eq)
  expect_equal(s$n_covariates, 3L)
  expect_equal(s$n_satisfied, 1L)
  expect_equal(s$n_satisfied_with_adjustment, 1L)
  expect_equal(s$n_not_satisfied, 1L)
  expect_equal(s$max_abs_effect, 0.30)
  expect_equal(s$overall, "not_satisfied")
})

test_that("wwc_summary verdict steps down when nothing is not_satisfied", {
  adj <- data.frame(
    covariate = c("a", "b"), effect_size = c(0.02, 0.10),
    wwc_category = c("satisfied", "satisfied_with_adjustment")
  )
  expect_equal(wwc_summary(adj)$overall, "satisfied_with_adjustment")
  ok <- data.frame(
    covariate = c("a", "b"), effect_size = c(0.02, 0.03),
    wwc_category = c("satisfied", "satisfied")
  )
  expect_equal(wwc_summary(ok)$overall, "satisfied")
})

test_that("wwc_summary works on a real baseline_equivalence result", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6)
  )
  s <- wwc_summary(baseline_equivalence(df, "treat"))
  expect_equal(s$n_covariates, 1L)
  expect_equal(s$overall, "not_satisfied")
})

test_that("wwc_summary validates input", {
  expect_error(wwc_summary(mtcars), "baseline_equivalence")
})

test_that("attrition computes overall and differential rates", {
  treatment <- c(rep(1L, 100), rep(0L, 100))
  retained <- c(rep(1L, 90), rep(0L, 10), rep(1L, 80), rep(0L, 20))
  a <- attrition(treatment, retained)
  expect_equal(a$attrition_treatment, 0.10)
  expect_equal(a$attrition_comparison, 0.20)
  expect_equal(a$attrition_overall, 0.15)
  expect_equal(a$differential_attrition, 0.10)
})

test_that("attrition accepts logical retained", {
  treatment <- c(1, 1, 0, 0)
  a <- attrition(treatment, c(TRUE, FALSE, TRUE, TRUE))
  expect_equal(a$attrition_treatment, 0.5)
  expect_equal(a$attrition_comparison, 0.0)
})

test_that("attrition validates its inputs", {
  expect_error(attrition(1:3, c(1, 0)), "same length")
  expect_error(attrition(c(1, 1, 0, 0), c(1, 2, 1, 0)), "0/1")
  expect_error(attrition(c(1, 1, 1), c(1, 0, 1)), "exactly two")
})
