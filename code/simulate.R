#' first commit
#' @param n length of sequence to simulate
#' @param scenario name of scenario that specifies mean function
#' @param pve the proportion of variance explained by the mean variation
#' @details The mean vector is simulated using the function scenario.fn
#' For example, for scenario "spikes" the mean is simulated using the function spikes.fn
simulate.gaussian.1d = function(n,scenario= c("spikes","bumps","blocks","angles","doppler","blip"), pve = 0.9) {
  if(pve<=0 || pve>=1){stop("pve must be strictly between 0 and 1")}
  scenario=match.arg(scenario)

  t = seq(0,1,length=n)
  meanfn = paste0(scenario,".fn")
  mu = do.call(meanfn, list(t))

  sigma = sd(mu) * sqrt((1-pve)/pve)
  y = rnorm(n, mu, sigma)
  return(list(y=y,t=t,mu=mu,sigma=sigma))
}



simulate_gaussian_1d_irregular = function(n,scenario= c("spikes","bumps","blocks","angles","doppler","blip"), pve = 0.9) {
  if(pve<=0 || pve>=1){stop("pve must be strictly between 0 and 1")}
  scenario=match.arg(scenario)

  #simulate irregular spaced x
  x = sort(runif(n, 0, 1))

  meanfn = paste0(scenario,".fn")
  mu = do.call(meanfn, list(x))

  #simulate y
  sigma = sd(mu) * sqrt((1-pve)/pve)
  y = rnorm(n, mu, sigma)
  return(list(x=x,y=y,mu=mu,sigma=sigma))
}

simulate_hard_tf = function(n, residual_variance, base_value, change_value){
  mu = c(rep(base_value,floor(n/2)),rep(change_value,2),rep(base_value, n-floor(n/2)-2))
  y = mu + rnorm(n, sd=sqrt(residual_variance))
  return(list(y=y,mu=mu))
}

#' @title this function randomly simulates piecewise-constant data
#' @param n the number of data points
#' @param cp_num the number of change points
#' @param residual_variance residual variance for the data
#' @return a list includes simulated data and ground truth trend
simulate_tf_order0 = function(n, cp_num, residual_variance){
  if (cp_num > n) {
    stop("The number of change points should be smaller than the number of data points.")
  }
  cp_idx = sort((sample(n, cp_num)))
  y_grid = 2*seq(-20, 50) #assume the number of change points is less than 140
  cp_val = y_grid[sample(length(y_grid), cp_num+1)]
  mu = create_tf_order0_mu(n, cp_idx, cp_val)
  y = mu + rnorm(n, sd=sqrt(residual_variance))
  return(list(y=y, mu=mu))
}

create_tf_order0_mu = function(n, cp_idx, cp_val){
  cp_idx = c(0, cp_idx, n)
  interval = diff(cp_idx)
  mu = numeric()
  for (i in 1:length(cp_val)) {
    mu = c(mu, rep(cp_val[i], interval[i]))
  }
  return(mu)
}




spikes.fn = function(t) {
  (0.75 * exp(-500 * (t - 0.23)^2) + 1.5 * exp(-2000 * (t - 0.33)^2) + 3 * exp(-8000 * (t - 0.47)^2) + 2.25 * exp(-16000 * (t - 0.69)^2) + 0.5 * exp(-32000 * (t - 0.83)^2))
}


bumps.fn = function(t) {
  pos = c(0.1, 0.13, 0.15, 0.23, 0.25, 0.4, 0.44, 0.65, 0.76, 0.78, 0.81)
  hgt = 2.97/5 * c(4, 5, 3, 4, 5, 4.2, 2.1, 4.3, 3.1, 5.1, 4.2)
  wth = c(0.005, 0.005, 0.006, 0.01, 0.01, 0.03, 0.01, 0.01, 0.005, 0.008, 0.005)
  fn = rep(0, length(t))
  for (j in 1:length(pos)) {
    fn = fn + hgt[j]/((1 + (abs(t - pos[j])/wth[j]))^4)
  }
  return((1 + fn)/5)
}

blocks.fn = function(t) {
  pos = c(0.1, 0.13, 0.15, 0.23, 0.25, 0.4, 0.44, 0.65, 0.76, 0.78, 0.81)
  hgt = 2.88/5 * c(4, (-5), 3, (-4), 5, (-4.2), 2.1, 4.3, (-3.1), 2.1, (-4.2))
  fn = rep(0, length(t))
  for (j in 1:length(pos)) {
    fn = fn + (1 + sign(t - pos[j])) * (hgt[j]/2)
  }
  return(0.2 + 0.6 * (fn - min(fn))/max(fn - min(fn)))
}

angles.fn = function(t) {
  sig = ((2 * t + 0.5) * (t <= 0.15)) + ((-12 * (t - 0.15) + 0.8) * (t > 0.15 & t <= 0.2)) + 0.2 * (t > 0.2 & t <= 0.5) + ((6 * (t - 0.5) + 0.2) * (t > 0.5 & t <= 0.6)) + ((-10 * (t - 0.6) + 0.8) * (t > 0.6 & t <= 0.65)) + ((-0.5 * (t - 0.65) + 0.3) * (t > 0.65 & t <= 0.85)) + ((2 * (t - 0.85) + 0.2) * (t > 0.85))
  fn = 3/5 * ((5/(max(sig) - min(sig))) * sig - 1.6) - 0.0419569
  return((1 + fn)/5)
}

doppler.fn = function(t) {
  dop.f = function(x) sqrt(x * (1 - x)) * sin((2 * pi * 1.05)/(x + 0.05))
  fn = dop.f(t)
  fn = 3/(max(fn) - min(fn)) * (fn - min(fn))
  return((1 + fn)/5)
}


blip.fn = function(t) {
  fn = (0.32 + 0.6 * t + 0.3 * exp(-100 * (t - 0.3)^2)) * (t >= 0 & t <= 0.8) + (-0.28 + 0.6 * t + 0.3 * exp(-100 * (t - 1.3)^2)) * (t > 0.8 & t <= 1)
  return(fn)
}

# cor.fn = function(t, type) {
#   fn = 623.87 * t^3 * (1 - 2 * t) * (t >= 0 & t <= 0.5) + 187.161 * (0.125 - t^3) * t^4 * (t > 0.5 & t <= 0.8) + 3708.470441 * (t - 1)^3 * (t > 0.8 & t <= 1)
#   fn = (0.6/(max(fn) - min(fn))) * fn
#   return(fn - min(fn) + 0.2)
# }

# cblocks.fn = function(t, type) {
#   pos = c(0.1, 0.13, 0.15, 0.23, 0.25, 0.4, 0.44, 0.65, 0.76, 0.78, 0.81)
#   hgt = 2.88/5 * c(4, (-5), 3, (-4), 5, (-4.2), 2.1, 4.3, (-3.1), 2.1, (-4.2))
#   fn = rep(0, length(t))
#   for (j in 1:length(pos)) {
#     fn = fn + (1 + sign(t - pos[j])) * (hgt[j]/2)
#   }
#   fn[fn < 0] = 0
#   if (type == "mean") {
#     return(NULL)
#   } else if (type == "var") {
#     return(1e-05 + 1 * (fn - min(fn))/max(fn))
#   }
# }
#
#
# texp.fn = function(t, type) {
#   fn = 1e-04 + 4 * (exp(-550 * (t - 0.2)^2) + exp(-200 * (t - 0.5)^2) + exp(-950 * (t - 0.8)^2))
#   if (type == "mean") {
#     return(NULL)
#   } else if (type == "var") {
#     return(fn)
#   }
# }
#
#
# cons.fn = function(t, type) {
#   fn = rep(1, length(t))
#   if (type == "mean") {
#     return(NULL)
#   } else if (type == "var") {
#     return(fn)
#   }
# }

