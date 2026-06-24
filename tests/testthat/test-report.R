test_that("love_plot returns a ggplot object", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  p <- love_plot(baseline_equivalence(df, "treat"))
  expect_true(inherits(p, "ggplot") || inherits(p, "ggplot2::ggplot"))
})

test_that("love_plot accepts the signed option", {
  skip_if_not_installed("ggplot2")
  df <- data.frame(treat = c(1, 1, 1, 0, 0, 0), pretest = c(5, 6, 7, 4, 5, 6))
  p <- love_plot(baseline_equivalence(df, "treat"), signed = TRUE)
  expect_true(inherits(p, "ggplot") || inherits(p, "ggplot2::ggplot"))
})

test_that("love_plot rejects non-equivalence input", {
  skip_if_not_installed("ggplot2")
  expect_error(love_plot(mtcars), "baseline_equivalence")
})

test_that("gt_baseline returns a gt_tbl", {
  skip_if_not_installed("gt")
  df <- data.frame(
    treat = c(1, 1, 1, 0, 0, 0),
    pretest = c(5, 6, 7, 4, 5, 6),
    female = c(1, 0, 1, 0, 0, 1)
  )
  tbl <- gt_baseline(baseline_equivalence(df, "treat"))
  expect_s3_class(tbl, "gt_tbl")
})

test_that("gt_baseline rejects non-equivalence input", {
  skip_if_not_installed("gt")
  expect_error(gt_baseline(mtcars), "baseline_equivalence")
})
