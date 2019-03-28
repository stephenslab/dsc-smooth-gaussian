# pipeline variables
# ==================
# $X an n vector of data x-axis (data could be irregularly spaced)
# $Y an n vector of data y-axis
# $mu_true an n vector of true means
# $sigma a scalar of residual standard deviation
# $mu_est an n vector of estimated means
# $error a scalar measure of accuracy.

# module groups
# =============
# simulate: -> $Y, $mu_true
# analyze: $Y -> $mu_est
# score: $mu_true, $mu_est -> $error

# simulate modules

sim_gauss: simulate.R + R(data = simulate.gaussian.1d(n,scenario,pve))
  n: 100, 128, 200, 256, 300
  pve: 0.5, 0.9, 0.95, 0.99
  scenario: spikes, bumps, blocks, angles, doppler, blip
  $X: data$x
  $Y: data$y
  $sigma: data$sigma
  $mu_true: data$mu



# analyze

# susie with Haar wavelet
susie_haar: susie_analyze.R + R(res=susie.wavelet(x,y,wavelet_type,estimate_residual_variance_MAD))
  x: $X
  y: $Y
  wavelet_type: Haar
  estimate_residual_variance_MAD: FALSE
  $mu_est: predict(res)
  
# susie with Symlet wavelet
susie_s10(susie_haar):
  wavelet_type: Symlet
  
# susie with Haar wavelet and use MAD
susie_haar_MAD(susie_haar):
  estimate_residual_variance_MAD: TRUE
  
# susie with Symlet wavelet and use MAD
susie_s10_MAD(susie_s10):
  estimate_residual_variance_MAD: TRUE
  

# smash with Haar wavelet
smash_haar: smash_analyze.R + R(res=smash.wavelet(mu_true, y,model="gaus",filter.number=fnum,family=family))
  mu_true: $mu_true
  fnum: 1
  family: DaubExPhase
  y: $Y
  $mu_true: res$mu_reflect
  $mu_est: res$s

# smash with Symlet 8 wavelet
smash_s8(smash_haar):
  fnum: 8
  family: DaubLeAsymm
  
# smash with Symlet 10 wavelet
smash_s10(smash_s8):
  fnum: 10



# score

mse: R(e = mean((a-b)^2))
  a: $mu_est
  b: $mu_true
  $error: e


DSC:
  define:
    simulate: sim_gauss
    analyze: susie_haar, susie_s10, susie_haar_MAD, susie_s10_MAD, smash_haar, smash_s8, smash_s10
    score: mse
  run: simulate * analyze * score
  exec_path: code
  R_libs: genlasso, smashr@stephenslab/smashr, susieR@stephenslab/susieR, wavethresh
