library(susieR)
library(wavethresh)

susie_wavelet = function(x, y, wavelet_type, estimate_residual_variance_MAD=FALSE){
  m = as.numeric(ceiling(1/quantile(sort(abs(diff(x))),0.1)))
  K = 2^(ceiling(log2(m)))
  R = create_interpolation_matrix(x)
  if(wavelet_type=="Haar"){
    Wt = GenW(n=K, filter.number=1, family="DaubExPhase")
  } else if(wavelet_type=="Symlet"){
    Wt = GenW(n=K, filter.number=10, family="DaubLeAsymm", bc="periodic")
  } else{
    stop("wavelet_type should be either Haar or Symlet.")
  }
  RWt = R %*% Wt

  if(estimate_residual_variance_MAD){
    #estimate residual variance using MAD method first, run susie
    #initialize from the susie fit above
    est.resid = estimate_residual_variance_MAD(y)
    s.est_resid= susie(RWt, y, L=50, estimate_prior_variance = TRUE, estimate_prior_method = 'optim', estimate_residual_variance = FALSE, residual_variance = est.resid)
    res = susie(RWt, y, estimate_prior_variance = TRUE, estimate_prior_method = 'optim', s_init = s.est_resid)
    return(res)
  }
  #run susie with fixed residual variance as an initialization
  s.fix = susie(RWt, y, L=50, estimate_prior_variance = TRUE, estimate_prior_method = 'optim', estimate_residual_variance = FALSE, residual_variance = 0.01)
  res = susie(RWt, y, estimate_prior_variance = TRUE, estimate_prior_method = 'optim', s_init = s.fix)
  return(res)
}

estimate_residual_variance_MAD = function(y){
  n = length(y)
  y_reflect = c(y, rev(y))
  J = floor(log2(2*n))
  y_reflect = y_reflect[1:2^J]
  y_reflect = c(y_reflect, rev(y_reflect))
  ywd <- wd(y_reflect, filter.number=1, family="DaubExPhase")
  wc_d = accessD(ywd, level=J-1)
  est.resid = (median(abs(wc_d))/0.6745)^2
  return(est.resid)
}

#' @param x is an n-vector of data
#' @return R an n by K interpolation matrix
create_interpolation_matrix = function(x){
  n = length(x)
  #m = 10% * abs(x_i - x_{i+1})
  m = as.numeric(ceiling(1/quantile(sort(abs(diff(x))),0.1)))
  K = 2^(ceiling(log2(m)))
  R = matrix(0, n, K)
  for (i in 1:n){
    for (j in 1:K){
      if (j == 1 & x[i] <= 1/K){
        R[i,j] = 1
      } else if (j == floor(K*x[i]) & x[i] > 1/K & x[i] <=1){
        R[i,j] = (j+1) - K*x[i]
      } else if (j == ceiling(K*x[i]) & x[i] > 1/K & x[i] <=1){
        R[i,j] = K*x[i] - (j-1)
      } else R[i,j] = 0
    }
  }
  return(R)
}

susie_tf_analyze = function(y, order, use_MAD_init, use_small_residual_variance_init, use_MAD_only){
  if (use_MAD_only){
    MAD_est = estimate_residual_variance_MAD(y)
    s = susie_trendfilter(y, order, estimate_residual_variance=FALSE, residual_variance=MAD_est)
  }
  if (use_MAD_init){
    MAD_est = estimate_residual_variance_MAD(y)
    s_init = susie_trendfilter(y, order, estimate_residual_variance=FALSE, residual_variance=MAD_est)
    s = susie_trendfilter(y, order, s_init=s_init)
  }
  if (use_small_residual_variance_init){
    s_init = susie_trendfilter(y, order, estimate_residual_variance=FALSE, residual_variance=0.01)
    s = susie_trendfilter(y, order, s_init=s_init)
  }
  if (!use_MAD_init & !use_small_residual_variance_init & !use_MAD_only){
    s = susie_trendfilter(y, order)
  }
  return(s)
}

estimate_residual_variance_MAD = function(y){
  n = length(y)
  y_reflect = c(y, rev(y))
  J = floor(log2(2*n))
  y_reflect = y_reflect[1:2^J]
  y_reflect = c(y_reflect, rev(y_reflect))
  ywd <- wd(y_reflect, filter.number=1, family="DaubExPhase")
  wc_d = accessD(ywd, level=J-1)
  est.resid = (median(abs(wc_d))/0.6745)^2
  return(est.resid)
}






