test_that("attrition_boundary matches WWC Handbook v4.1 Table II.1 anchors", {
  # overall 0%: cautious boundary 5.7pp, optimistic 10.0pp
  expect_equal(attrition_boundary(0.00, 0.057, "cautious")$attrition, "low")
  expect_equal(attrition_boundary(0.00, 0.058, "cautious")$attrition, "high")
  expect_equal(attrition_boundary(0.00, 0.100, "optimistic")$attrition, "low")
  expect_equal(attrition_boundary(0.00, 0.101, "optimistic")$attrition, "high")

  # overall 30%: cautious 4.1pp, optimistic 8.2pp -> 6pp differential differs
  expect_equal(attrition_boundary(0.30, 0.06, "cautious")$attrition, "high")
  expect_equal(attrition_boundary(0.30, 0.06, "optimistic")$attrition, "low")

  # cautious "-" region (overall >= 58%): always high; optimistic still defined
  expect_equal(attrition_boundary(0.60, 0.00, "cautious")$attrition, "high")
  expect_equal(attrition_boundary(0.60, 0.014, "optimistic")$attrition, "low")

  # boundary value is returned as a proportion
  expect_equal(attrition_boundary(0.00, 0.03, "cautious")$max_differential, 0.057)
})

test_that("attrition_boundary guards units and missing values", {
  expect_warning(attrition_boundary(30, 6)) # looks like percentages
  expect_true(is.na(attrition_boundary(NA, 0.03)$attrition))
  expect_error(attrition_boundary(c(0.1, 0.2), 0.03))
})
