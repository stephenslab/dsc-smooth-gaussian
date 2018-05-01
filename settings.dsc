# pipeline variables
# ==================
# $Y an n vector of data
# $mu an n vector of true means
# #mu_est an n vector of estimated means
# $error a scalar measure of accuracy.

# module groups
# =============
# simulate: -> $Y, $mu_true
# analyze: $Y -> $mu_est
# score: $mu_true, $mu_est -> $error

# simulate modules

sim_gauss: simulate.R + R(data = simulate.gaussian.1d(n,scenario,pve))
  n: 256
  pve: 0.5, 0.9, 0.95
  scenario: spikes, bumps, blocks, angles, doppler, blip
  $Y: data$y
  $mu_true: data$mu

# analyze

# smash with haar wavelet
smash: R(library(smashr); res = smash(y,model="gaus",filter.number=fnum,family=family))
  fnum: 1
  family: DaubExPhase
  y: $Y
  $mu_est: res

# smash with symm 8 wavelet
smash_s8(smash):
  fnum: 8
  family: DaubLeAsymm


trend1: R(library(genlasso); y.tf = trendfilter(y,ord=ord); y.tf.cv = cv.trendfilter(y.tf); muhat = coef(y.tf,y.tf.cv$lambda.min)$beta)
  ord: 1
  y: $Y
  $mu_est: muhat

# second order trend filter
trend2(trend1):
  ord: 2

# score

mse: R(e = mean((a-b)^2))
  a: $mu_est
  b: $mu_true
  $error: e


DSC:
  define:
    simulate: sim_gauss
    analyze: smash, smash_s8, trend1, trend2
    score: mse
  run: simulate * analyze * score
  exec_path: code
  R_libs: genlasso, smashr@stephenslab/smashr
