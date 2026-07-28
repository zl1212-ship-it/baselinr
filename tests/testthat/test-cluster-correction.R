test_that("cluster_correction degenerates to no correction at ICC = 0", {
  cc <- cluster_correction(0.3, 200, 200, 10, 10, icc = 0)
  # t is unchanged and df returns to N - 2
  expect_equal(cc$t_corrected, cc$t)
  expect_equal(cc$df, 398)
})

test_that("a positive ICC reduces the corrected t, df, and significance", {
  cc <- cluster_correction(0.3, 200, 200, 10, 10, outcome = "achievement")
  base <- cluster_correction(0.3, 200, 200, 10, 10, icc = 0)
  expect_lt(cc$t_corrected, base$t_corrected)
  expect_lt(cc$df, base$df)
  expect_gt(cc$p_value, base$p_value)
  expect_true(all(c("t", "t_corrected", "df", "p_value", "significant") %in% names(cc)))
})

test_that("default ICC follows outcome type", {
  a <- cluster_correction(0.3, 200, 200, 10, 10, outcome = "achievement") # 0.20
  o <- cluster_correction(0.3, 200, 200, 10, 10, outcome = "other")       # 0.10
  # the larger ICC (achievement) corrects more strongly
  expect_lt(a$t_corrected, o$t_corrected)
})
