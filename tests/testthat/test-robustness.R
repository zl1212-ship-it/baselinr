mkvec <- function(n, m, s) {
  z <- 1:n
  z <- z - mean(z)
  z <- z / sd(z)
  m + s * z
}

test_that("wwc_robustness returns the expected structure", {
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  r <- wwc_robustness(df, "treat")
  expect_s3_class(r, "data.frame")
  expect_true(all(c(
    "covariate", "type", "category_default", "categories", "flips",
    "abs_es_min", "abs_es_max"
  ) %in% names(r)))
  expect_false(is.null(attr(r, "overall")))
  expect_type(attr(r, "overall_stable"), "logical")
})

test_that("a verdict far from the thresholds is stable", {
  df <- data.frame(
    treat = c(rep(1, 100), rep(0, 100)),
    x = c(mkvec(100, 0, 1), mkvec(100, 0, 1)) # identical groups -> g = 0
  )
  r <- wwc_robustness(df, "treat")
  expect_true(all(!r$flips))
  expect_true(attr(r, "overall_stable"))
})

test_that("a verdict straddling the 0.25 line is flagged as flipping", {
  # heteroscedastic groups: pooled-SD g ~ 0.29 (not_satisfied),
  # comparison-SD g ~ 0.21 (satisfied_with_adjustment)
  df <- data.frame(
    treat = c(rep(1, 200), rep(0, 200)),
    x = c(mkvec(200, 0.42, 0.5), mkvec(200, 0, 2))
  )
  r <- wwc_robustness(df, "treat")
  expect_true(r$flips[r$covariate == "x"])
  expect_false(attr(r, "overall_stable"))
})
