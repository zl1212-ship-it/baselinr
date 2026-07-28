#' WWC clustering correction for mismatched analyses
#'
#' Corrects the statistical significance of a finding for clustering, following
#' the What Works Clearinghouse (WWC) procedure based on Hedges (2007). The
#' correction applies when assignment was at the cluster level (classrooms or
#' schools) but the analysis was at the student level, a "mismatch" that leaves
#' the reported standard errors too small. It computes the t statistic implied
#' by the effect size, then corrects both the t statistic and its degrees of
#' freedom for clustering, and returns the clustering-corrected two-tailed
#' p value and significance decision.
#'
#' Because the correction can only reduce significance, the WWC applies it only
#' to findings the study authors reported as statistically significant; a finding
#' that was not significant stays not significant. This function computes the
#' corrected values regardless; apply them where the WWC rules call for it.
#'
#' @param g Effect size (Hedges' g) ignoring clustering.
#' @param n_treatment,n_comparison Student-level sample sizes.
#' @param m_treatment,m_comparison Number of clusters in each group.
#' @param icc Intraclass correlation. If `NULL` (default), the WWC default is
#'   used: 0.20 for `outcome = "achievement"`, 0.10 otherwise.
#' @param outcome `"achievement"` or `"other"`, selecting the default ICC when
#'   `icc` is `NULL`.
#'
#' @return A data frame, one row per input, with columns `t` (ignoring
#'   clustering), `t_corrected`, `df` (corrected degrees of freedom), `p_value`
#'   (clustering-corrected, two-tailed), and `significant` (`p_value < 0.05`).
#'
#' @references What Works Clearinghouse (2020). *Procedures Handbook, Version
#'   4.1*, Appendix F. Hedges, L. V. (2007). Effect sizes in cluster-randomized
#'   designs. *Journal of Educational and Behavioral Statistics*, 32(4), 341-370.
#'
#' @examples
#' # A finding with a moderate effect from a clustered design:
#' cluster_correction(
#'   g = 0.30, n_treatment = 200, n_comparison = 200,
#'   m_treatment = 10, m_comparison = 10, outcome = "achievement"
#' )
#'
#' @importFrom stats pt
#' @export
cluster_correction <- function(g, n_treatment, n_comparison,
                               m_treatment, m_comparison,
                               icc = NULL, outcome = c("achievement", "other")) {
  outcome <- match.arg(outcome)
  rho <- if (is.null(icc)) {
    if (identical(outcome, "achievement")) 0.20 else 0.10
  } else {
    icc
  }

  n_i <- n_treatment
  n_c <- n_comparison
  N <- n_i + n_c
  M <- m_treatment + m_comparison
  n_bar <- N / M # average cluster size

  # [F.1.0] t ignoring clustering
  t <- g / sqrt((n_i + n_c) / (n_i * n_c) + g^2 / (2 * (n_i + n_c)))

  a <- (N - 2) - 2 * (n_bar - 1) * rho # shared numerator term

  # [F.1.1] correct the t statistic
  t_corrected <- t * sqrt(a / ((N - 2) * (1 + (n_bar - 1) * rho)))

  # [F.1.2] corrected degrees of freedom
  df <- a^2 / (
    (N - 2) * (1 - rho)^2 +
      n_bar * (N - 2 * n_bar) * rho^2 +
      2 * (N - 2 * n_bar) * rho * (1 - rho)
  )

  # [F.1.4] two-tailed p from the t distribution with corrected t and df
  p <- 2 * pt(-abs(t_corrected), df = df)

  data.frame(
    t = t,
    t_corrected = t_corrected,
    df = df,
    p_value = p,
    significant = p < 0.05,
    stringsAsFactors = FALSE
  )
}
