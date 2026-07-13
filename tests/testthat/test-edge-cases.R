# Edge-case coverage for the effect-size functions and the table builder:
# zero variance, minimum and extremely imbalanced group sizes, missing data,
# degenerate proportions, and empty input. See issue #3.

# ---- hedges_g ---------------------------------------------------------------

test_that("hedges_g works at the minimum valid group size (two per group)", {
  # comparison = c(5, 7), treated = c(4, 6); diff = -1, s_pooled = sqrt(2),
  # d = -1/sqrt(2); N = 4, correction = 1 - 3/7; g = -0.404061
  expect_equal(hedges_g(c(4, 6, 5, 7), c(1, 1, 0, 0)), -0.404061, tolerance = 1e-6)
})

test_that("hedges_g handles extremely imbalanced group sizes", {
  # Two treated vs. ten comparison: should still return a single finite value
  # with the small-sample correction applied (not error on unequal n).
  treated <- c(10, 12)
  comparison <- 0:9
  g <- hedges_g(c(treated, comparison), c(1, 1, rep(0, 10)))
  expect_length(g, 1L)
  expect_true(is.finite(g))
  expect_gt(g, 0) # treated mean is higher
})

test_that("hedges_g with na.rm = FALSE errors on missing data", {
  # With na.rm = FALSE, missing values are rejected up front with a clear
  # message, matching cox_index below (see issue #12).
  x <- c(5, 6, 7, NA, 4, 5, 6)
  g <- c(1, 1, 1, 1, 0, 0, 0)
  expect_error(hedges_g(x, g, na.rm = FALSE), "Missing values present")
})

test_that("hedges_g errors when all data is missing", {
  expect_error(
    hedges_g(c(NA_real_, NA_real_, NA_real_, NA_real_), c(1, 1, 0, 0)),
    "exactly two"
  )
})

# ---- cox_index --------------------------------------------------------------

test_that("cox_index is zero when the two group proportions are equal", {
  # p_t = p_c = 0.5 -> logit difference is zero -> perfect equivalence.
  expect_equal(cox_index(c(1, 0, 1, 0), c(1, 1, 0, 0)), 0)
})

test_that("cox_index returns NA when the comparison proportion is zero", {
  # comparison group has no events (p_c = 0); index is undefined.
  x <- c(1, 1, 0, 0, 0, 0) # treatment events present, comparison all non-event
  g <- c(1, 1, 1, 0, 0, 0)
  expect_warning(r <- cox_index(x, g), "undefined")
  expect_true(is.na(r))
})

test_that("cox_index with na.rm = FALSE errors on missing data", {
  # With na.rm = FALSE, missing values are rejected up front with a clear
  # message, matching hedges_g above (see issue #12).
  x <- c(1, 1, 0, NA, 1, 0, 0, 1)
  g <- c(1, 1, 1, 1, 0, 0, 0, 0)
  expect_error(cox_index(x, g, na.rm = FALSE), "Missing values present")
})

# ---- wwc_classify -----------------------------------------------------------

test_that("wwc_classify returns an empty vector for empty input", {
  expect_equal(wwc_classify(numeric(0)), character(0))
})

test_that("wwc_classify keeps NA entries within a vector", {
  expect_equal(
    wwc_classify(c(0.02, NA, 0.30)),
    c("satisfied", NA, "not_satisfied")
  )
})

# ---- baseline_equivalence ---------------------------------------------------

test_that("baseline_equivalence drops missing rows per covariate", {
  # Row 3 (treatment) has a missing pretest and is dropped for that covariate,
  # so n_treatment reflects complete cases only.
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pre = c(5, 6, NA, 4, 5, 6)
  )
  res <- baseline_equivalence(df, "treat")
  expect_equal(res$n_treatment, 2L)
  expect_equal(res$n_comparison, 3L)
  expect_equal(res$effect_size, 0.3983437, tolerance = 1e-6)
})

test_that("baseline_equivalence errors on a zero-variance continuous covariate", {
  df <- data.frame(treat = c(1, 1, 0, 0), x = c(5, 5, 5, 5))
  expect_error(baseline_equivalence(df, "treat"), "zero")
})

test_that("baseline_equivalence yields NA category for a degenerate binary covariate", {
  # Treatment proportion is 1 (all events) -> Cox index undefined -> effect_size
  # and wwc_category are NA rather than erroring the whole table.
  df <- data.frame(
    treat = c(1, 1, 1, 1, 0, 0, 0, 0),
    b = c(1, 1, 1, 1, 1, 0, 0, 0) # p_t = 1
  )
  expect_warning(res <- baseline_equivalence(df, "treat"))
  expect_true(is.na(res$effect_size))
  expect_true(is.na(res$wwc_category))
})

test_that("baseline_equivalence handles extremely imbalanced groups", {
  df <- data.frame(
    treat = c(1, 1, rep(0, 10)),
    pre = c(10, 12, 0:9)
  )
  res <- baseline_equivalence(df, "treat")
  expect_equal(res$n_treatment, 2L)
  expect_equal(res$n_comparison, 10L)
  expect_true(is.finite(res$effect_size))
})
