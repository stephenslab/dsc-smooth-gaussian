# pipeline variables
# ==================
# $X an n vector of data x-axis (data could be irregularly spaced)
# $Y an n vector of data y-axis
# $mu_true an n vector of true means
# $mu_est an n vector of estimated means
# $error a scalar measure of accuracy.

# module groups
# =============
# simulate: -> $Y, $mu_true
# analyze: $Y -> $mu_est
# score: $mu_true, $mu_est -> $error

# simulate modules
sim_gauss: R(data = simulate_tf_order0(n, cp_num, residual_sd))
  n: 100, 300, 500, 1000, 2000
  cp_num: 1, 3, 5, 10, 15, 30, 50
  residual_sd: 0.001, 0.01, 0.02, 0.03, 0.05, 0.1
  $Y: data$y
  $mu_true: data$mu

# analyze
susie_tf: R(fit = susie_tf_analyze(y, order, use_MAD_init, use_small_residual_variance_init, use_MAD_only))
  y: $Y
  order: 0
  use_MAD_init: FALSE
  use_small_residual_variance_init: FALSE
  use_MAD_only: FALSE
  $mu_est: predict(fit)

susie_tf_MAD_only(susie_tf):
  use_MAD_only: TRUE

susie_tf_MAD_init(susie_tf):
  use_MAD_init: TRUE

susie_tf_smallresid_init(susie_tf):
  use_small_residual_variance_init: TRUE

naive_method: R(mu_est = rep(mean(y), length(y)))
  y: $Y
  $mu_est: mu_est


# score
mse: R(e = compute_mse(mu_est, mu_true))
  mu_est: $mu_est
  mu_true: $mu_true
  $error: e

DSC:
  define:
    simulate: sim_gauss
    analyze: susie_tf, susie_tf_MAD_only, susie_tf_MAD_init, susie_tf_smallresid_init, naive_method
    score: mse
  run: simulate * analyze * score
  lib_path: code
  R_libs: susieR@stephenslab/susieR, wavethresh, susieR@stephenslab/smashr



