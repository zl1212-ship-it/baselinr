# Generates `data/tutoring.rda`: a SIMULATED (not real) quasi-experimental
# tutoring program evaluation, used in examples and the vignette.
# Run with: source("data-raw/tutoring.R")

set.seed(3)

sim_group <- function(n, m_pre, p_female, p_frpl, p_ell, m_att, m_age) {
  data.frame(
    pretest    = rnorm(n, mean = m_pre, sd = 10),
    attendance = pmin(1, pmax(0, rnorm(n, mean = m_att, sd = 0.06))),
    age        = round(rnorm(n, mean = m_age, sd = 0.5), 1),
    female     = rbinom(n, 1, p_female),
    frpl       = rbinom(n, 1, p_frpl),
    ell        = rbinom(n, 1, p_ell)
  )
}

# Treatment group is mildly positively selected -> a spread of WWC categories.
treated <- sim_group(200, m_pre = 52, p_female = 0.50, p_frpl = 0.55,
                     p_ell = 0.22, m_att = 0.930, m_age = 10.05)
comparison <- sim_group(200, m_pre = 50, p_female = 0.50, p_frpl = 0.45,
                        p_ell = 0.14, m_att = 0.928, m_age = 10.00)

treated$treat <- 1L
comparison$treat <- 0L
tutoring <- rbind(treated, comparison)

# Outcome: relates to pretest, with a positive program effect.
tutoring$posttest <- round(
  0.8 * tutoring$pretest + 5 * tutoring$treat +
    rnorm(nrow(tutoring), mean = 10, sd = 8),
  1
)

tutoring <- tutoring[sample(nrow(tutoring)), ]
tutoring <- tutoring[, c(
  "treat", "pretest", "attendance", "age",
  "female", "frpl", "ell", "posttest"
)]
rownames(tutoring) <- NULL

usethis::use_data(tutoring, overwrite = TRUE)
