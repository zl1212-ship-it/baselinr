test_that("wwc_rating follows the WWC group-design decision path", {
  without <- "Meets WWC Group Design Standards Without Reservations"
  with_res <- "Meets WWC Group Design Standards With Reservations"
  does_not <- "Does Not Meet WWC Group Design Standards"

  # Low-attrition RCT meets without reservations regardless of baseline.
  expect_equal(as.character(wwc_rating("rct", "not_satisfied", "low")), without)
  expect_equal(as.character(wwc_rating("rct", "satisfied", "low")), without)

  # High-attrition RCT hinges on baseline equivalence, like a QED.
  expect_equal(as.character(wwc_rating("rct", "satisfied", "high")), with_res)
  expect_equal(
    as.character(wwc_rating("rct", "satisfied_with_adjustment", "high")),
    with_res
  )
  expect_equal(as.character(wwc_rating("rct", "not_satisfied", "high")), does_not)

  # QED cannot meet without reservations.
  expect_equal(as.character(wwc_rating("qed", "satisfied")), with_res)
  expect_equal(as.character(wwc_rating("qed", "not_satisfied")), does_not)
})

test_that("wwc_rating validates inputs", {
  expect_error(wwc_rating("rct", "satisfied")) # RCT needs attrition
  expect_error(wwc_rating("qed", "bogus")) # invalid baseline
  expect_error(wwc_rating("observational", "satisfied")) # invalid design
})
